#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'Used to create a secure string for testing.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', '',
    Justification = 'Log outputs to GitHub Actions logs.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidLongLines', '',
    Justification = 'Long test descriptions and skip switches'
)]
[CmdletBinding()]
param()

BeforeAll {
    $testName = 'ReleasesTests'
    $os = $env:RUNNER_OS
    $guid = [guid]::NewGuid().ToString()
}

Describe 'Releases' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-Table | Out-String)
            }
            if ($AuthType -eq 'APP') {
                LogGroup 'Context - Installation' {
                    $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                    Write-Host ($context | Format-Table | Out-String)
                }
            }
            $repoPrefix = "$testName-$os-$TokenType"
            $repoName = "$repoPrefix-$guid"

            $params = @{
                Name             = $repoName
                Context          = $context
                AllowSquashMerge = $true
                AddReadme        = $true
                License          = 'mit'
                Gitignore        = 'VisualStudio'
            }
            switch ($OwnerType) {
                'user' {
                    $repo = New-GitHubRepository @params
                }
                'organization' {
                    $repo = New-GitHubRepository @params -Organization $owner
                }
            }
            LogGroup "Repository - [$repoName]" {
                Write-Host ($repo | Format-Table | Out-String)
            }
        }

        AfterAll {
            switch ($OwnerType) {
                'user' {
                    Get-GitHubRepository | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                }
                'organization' {
                    Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                }
            }
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }

        Context 'Releases' -Skip:($OwnerType -eq 'repository') {
            It 'New-GitHubRelease - Creates a new release' {
                $release = New-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.0' -Latest
                LogGroup 'Release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
            }

            It 'New-GitHubRelease - Throws when tag already exists' {
                { New-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.0' -Latest } | Should -Throw
            }

            It 'New-GitHubRelease - Creates a new release with a draft' {
                $release = New-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.2' -Draft
                LogGroup 'Release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
                $release.IsDraft | Should -BeTrue
                $release.IsLatest | Should -BeFalse
                $release.IsPrerelease | Should -BeFalse
            }

            It 'New-GitHubRelease - Creates a new release with a pre-release' {
                $release = New-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.1' -Prerelease
                LogGroup 'Release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
                $release.Tag | Should -Be 'v1.1'
                $release.IsDraft | Should -BeFalse
                $release.IsLatest | Should -BeFalse
                $release.IsPrerelease | Should -BeTrue
            }

            It 'New-GitHubRelease - Creates a new release with a name' {
                $release = New-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.3' -Name 'Test Release' -GenerateReleaseNotes -Latest
                LogGroup 'Release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
            }

            It 'Get-GitHubRelease - Gets latest release' {
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo
                LogGroup 'Latest release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
                $release.Count | Should -Be 1
                $release | Should -BeOfType 'GitHubRelease'
                $release.Tag | Should -Be 'v1.3'
                $release.IsLatest | Should -BeTrue
            }

            It 'Get-GitHubRelease - Gets all releases' {
                $releases = Get-GitHubRelease -Owner $Owner -Repository $repo -All
                LogGroup 'All releases' {
                    Write-Host ($releases | Format-List -Property * | Out-String)
                }
                $releases | Should -Not -BeNullOrEmpty
                $releases.Count | Should -BeGreaterThan 1
                $releases | Should -BeOfType 'GitHubRelease'
            }

            It 'Get-GitHubRelease - Gets release by tag' {
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.2'
                LogGroup 'Release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
                $release.Count | Should -Be 1
                $release | Should -BeOfType 'GitHubRelease'
                $release.Tag | Should -Be 'v1.2'
                $release.IsLatest | Should -BeFalse
                $release.IsDraft | Should -BeTrue
            }

            It 'Get-GitHubRelease - Gets release by ID' {
                $specificRelease = Get-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.0'
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo -ID $specificRelease.ID
                LogGroup 'Release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
                $release.Count | Should -Be 1
                $release | Should -BeOfType 'GitHubRelease'
                $release.Tag | Should -Be 'v1.0'
                $release.IsLatest | Should -BeFalse
                $release.IsDraft | Should -BeFalse
                $release.IsPrerelease | Should -BeFalse
            }

            It 'Get-GitHubRelease - Gets release by ID using Pipeline' {
                $specificRelease = Get-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.2'
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo -ID $specificRelease.ID
                LogGroup 'Release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
                $release.Count | Should -Be 1
                $release | Should -BeOfType 'GitHubRelease'
                $release.Tag | Should -Be 'v1.2'
            }

            It 'Update-GitHubRelease - Update release v1.0' {
                $release = Update-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.0' -Name 'Updated Release' -Notes 'Updated release notes'
                LogGroup 'Updated release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
                $release.Name | Should -Be 'Updated Release'
                $release.Notes | Should -Be 'Updated release notes'
                $release.Tag | Should -Be 'v1.0'
                $release.IsLatest | Should -BeFalse
                $release.IsDraft | Should -BeFalse
                $release.IsPrerelease | Should -BeFalse
            }

            It 'Update-GitHubRelease - Update release v1.1' {
                $release = Update-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.1' -Name 'Updated Release' -Notes 'Updated release notes'
                LogGroup 'Updated release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
                $release.Name | Should -Be 'Updated Release'
                $release.Notes | Should -Be 'Updated release notes'
                $release.Tag | Should -Be 'v1.1'
                $release.IsLatest | Should -BeFalse
                $release.IsDraft | Should -BeFalse
                $release.IsPrerelease | Should -BeTrue
            }

            It 'Update-GitHubRelease - Update release v1.2' {
                $release = Update-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.2' -Name 'Updated Release' -Notes 'Updated release notes'
                LogGroup 'Updated release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
                $release.Name | Should -Be 'Updated Release'
                $release.Notes | Should -Be 'Updated release notes'
                $release.IsLatest | Should -BeFalse
                $release.IsDraft | Should -BeTrue
                $release.IsPrerelease | Should -BeFalse
            }

            It 'Update-GitHubRelease - Update release v1.3' {
                $release = Update-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.3' -Name 'Updated Release' -Notes 'Updated release notes'
                LogGroup 'Updated release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
                $release.Name | Should -Be 'Updated Release'
                $release.Notes | Should -Be 'Updated release notes'
                $release.Tag | Should -Be 'v1.3'
                $release.IsLatest | Should -BeTrue
                $release.IsDraft | Should -BeFalse
                $release.IsPrerelease | Should -BeFalse
            }

            It 'Set-GitHubRelease - Sets release v1.0 as latest' {
                $release = Set-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.0' -Latest -Name 'Updated Release again' -Notes 'Updated release notes to something else'
                LogGroup 'Set release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
                $release.Tag | Should -Be 'v1.0'
                $release.IsLatest | Should -BeTrue
                $release.IsDraft | Should -BeFalse
                $release.IsPrerelease | Should -BeFalse
                $release.Name | Should -Be 'Updated Release again'
                $release.Notes | Should -Be 'Updated release notes to something else'
            }

            It 'Set-GitHubRelease - Sets a new release as latest - v1.4' {
                $release = Set-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.4' -Latest -Name 'New Release' -Notes 'New release notes'
                LogGroup 'Set release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
                $release.Tag | Should -Be 'v1.4'
                $release.IsLatest | Should -BeTrue
                $release.IsDraft | Should -BeFalse
                $release.IsPrerelease | Should -BeFalse
                $release.Name | Should -Be 'New Release'
                $release.Notes | Should -Be 'New release notes'
            }

            It 'Remove-GitHubRelease - Removes release v1.0' {
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.0'
                $release | Should -Not -BeNullOrEmpty
                $release.Count | Should -Be 1
                $release | Should -BeOfType 'GitHubRelease'
                $release.Tag | Should -Be 'v1.0'
                $release.IsLatest | Should -BeFalse
                $release.IsDraft | Should -BeFalse
                $release.IsPrerelease | Should -BeFalse

                Remove-GitHubRelease -Owner $Owner -Repository $repo -ID $release.ID -Confirm:$false

                $release = Get-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.0'
                $release | Should -BeNullOrEmpty
            }
        }
        Context 'Release Assets' -Skip:($OwnerType -eq 'repository') {
            BeforeAll {
                $testFolderGuid = [Guid]::NewGuid().ToString().Substring(0, 8)
                $testFolderName = "GHAssetTest-$testFolderGuid"
                $testFolderPath = Join-Path -Path $PSScriptRoot -ChildPath $testFolderName
                New-Item -Path $testFolderPath -ItemType Directory -Force
                $testFiles = @{
                    TextFile     = @{
                        Name        = 'TextFile.txt'
                        Path        = Join-Path -Path $testFolderPath -ChildPath 'TextFile.txt'
                        Content     = @'
This is a simple text file for testing GitHub release assets
'@
                        ContentType = 'text/plain'
                    }
                    MarkdownFile = @{
                        Name        = 'Documentation.md'
                        Path        = Join-Path -Path $testFolderPath -ChildPath 'Documentation.md'
                        Content     = @'
# Test Documentation
## Introduction
This is a markdown file used for testing GitHub release assets
'@
                        ContentType = 'text/markdown'
                    }
                    JsonFile     = @{
                        Name        = 'Config.json'
                        Path        = Join-Path -Path $testFolderPath -ChildPath 'Config.json'
                        Content     = @'
{
  "name": "GitHub Release Asset Test",
  "version": "1.0.0",
  "description": "Test file for GitHub release assets"
}
'@
                        ContentType = 'application/json'
                    }
                    XmlFile      = @{
                        Name        = 'Data.xml'
                        Path        = Join-Path -Path $testFolderPath -ChildPath 'Data.xml'
                        Content     = @'
<root>
  <item id="1">
    <name>Test Item</name>
    <value>100</value>
  </item>
</root>
'@
                        ContentType = 'application/xml'
                    }
                    CsvFile      = @{
                        Name        = 'Records.csv'
                        Path        = Join-Path -Path $testFolderPath -ChildPath 'Records.csv'
                        Content     = @'
ID,Name,Value
1,Item1,100
2,Item2,200
3,Item3,300
'@
                        ContentType = 'text/csv'
                    }
                }
                foreach ($file in $testFiles.Values) {
                    Set-Content -Path $file.Path -Value $file.Content
                }

                # Create a zip file of all test files
                $zipFileName = "$testFolderName.zip"
                $zipFilePath = Join-Path -Path $env:TEMP -ChildPath $zipFileName
                Compress-Archive -Path "$testFolderPath\*" -DestinationPath $zipFilePath -Force

                # Add the zip file to the test files collection
                $testFiles['ZipFile'] = @{
                    Name        = $zipFileName
                    Path        = $zipFilePath
                    ContentType = 'application/zip'
                }

                # Get the latest release to use for tests
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo
            }

            AfterAll {
                if (Test-Path $testFolderPath) {
                    Remove-Item -Path $testFolderPath -Recurse -Force
                }
                if (Test-Path $testFiles.ZipFile.Path) {
                    Remove-Item -Path $testFiles.ZipFile.Path -Force
                }

                foreach ($file in $testFiles.Values) {
                    $downloadPath = Join-Path -Path $env:TEMP -ChildPath "Downloaded-$($file.Name)"
                    if (Test-Path $downloadPath) {
                        Remove-Item -Path $downloadPath -Force
                    }
                }
            }

            It 'Add-GitHubReleaseAsset - Creates a new release asset' {
                $asset = $release | Add-GitHubReleaseAsset -Path $testFiles.TextFile.Path
                LogGroup 'Added asset' {
                    Write-Host ($asset | Format-List -Property * | Out-String)
                }
                $asset | Should -Not -BeNullOrEmpty
                $asset | Should -BeOfType 'GitHubReleaseAsset'
                $asset.Name | Should -Be $testFiles.TextFile.Name
                $asset.Label | Should -Be $testFiles.TextFile.Name
                $asset.Size | Should -BeGreaterThan 0
                $asset.ContentType | Should -Be $testFiles.TextFile.ContentType

                $downloadPath = Join-Path -Path $env:TEMP -ChildPath "Downloaded-$($testFiles.TextFile.Name)"
                Invoke-WebRequest -Uri $asset.Url -OutFile $downloadPath
                Get-Content -Path $downloadPath | Should -Be $testFiles.TextFile.Content
            }

            It 'Add-GitHubReleaseAsset - Creates a release asset with custom parameters' {
                $customName = "Custom-$($testFiles.MarkdownFile.Name)"
                $label = 'Test Markdown Documentation'
                $asset = $release | Add-GitHubReleaseAsset -Path $testFiles.MarkdownFile.Path -Name $customName -Label $label
                LogGroup 'Added markdown asset' {
                    Write-Host ($asset | Format-List -Property * | Out-String)
                }
                $asset | Should -Not -BeNullOrEmpty
                $asset | Should -BeOfType 'GitHubReleaseAsset'
                $asset.Name | Should -Be $customName
                $asset.ContentType | Should -Be $testFiles.MarkdownFile.ContentType
                $asset.Label | Should -Be $label
                $asset.Size | Should -BeGreaterThan 0

                $downloadPath = Join-Path -Path $env:TEMP -ChildPath "Downloaded-$customName"
                Invoke-WebRequest -Uri $asset.Url -OutFile $downloadPath
                (Get-Content -Path $downloadPath -Raw) | Should -Match '# Test Documentation'
            }

            It 'Add-GitHubReleaseAsset - Adds a folder as a zipped asset to a release' {
                $label = 'Test Files Collection'
                $asset = $release | Add-GitHubReleaseAsset -Label $label -Path $testFiles.ZipFile.Path
                LogGroup 'Added zip asset' {
                    Write-Host ($asset | Format-List -Property * | Out-String)
                }
                $asset | Should -Not -BeNullOrEmpty
                $asset.Name | Should -Be $testFiles.ZipFile.Name
                $asset.Label | Should -Be $label
                $asset.ContentType | Should -Be $testFiles.ZipFile.ContentType
                $asset.Size | Should -BeGreaterThan 0

                $downloadPath = Join-Path -Path $env:TEMP -ChildPath "Downloaded-$($testFiles.ZipFile.Name)"
                Invoke-WebRequest -Uri $asset.Url -OutFile $downloadPath
                Test-Path -Path $downloadPath | Should -BeTrue
            }

            It 'Get-GitHubReleaseAsset - Gets all assets from a release ID' {
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo
                $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
                LogGroup 'Release assets by release ID' {
                    Write-Host ($assets | Format-List -Property * | Out-String)
                }
                $assets | Should -Not -BeNullOrEmpty
                $assets.Count | Should -Be 3
                $assets | Should -BeOfType 'GitHubReleaseAsset'
            }

            # It 'Get-GitHubReleaseAsset - Gets a specific asset by ID' {
            #     $release = Get-GitHubRelease -Owner $Owner -Repository $repo
            #     $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
            #     $asset = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ID $assets[0].ID
            #     LogGroup 'Release asset by asset ID' {
            #         Write-Host ($asset | Format-List -Property * | Out-String)
            #     }
            #     $asset | Should -Not -BeNullOrEmpty
            #     $asset | Should -BeOfType 'GitHubReleaseAsset'
            #     $asset.ID | Should -Be $assets[0].ID
            # }

            # It 'Get-GitHubReleaseAsset - Gets a specific asset by name from a release ID' {
            #     $release = Get-GitHubRelease -Owner $Owner -Repository $repo
            #     $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
            #     $assetName = $assets[0].Name
            #     $asset = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID -Name $assetName
            #     LogGroup 'Release asset by name from release ID' {
            #         Write-Host ($asset | Format-List -Property * | Out-String)
            #     }
            #     $asset | Should -Not -BeNullOrEmpty
            #     $asset | Should -BeOfType 'GitHubReleaseAsset'
            #     $asset.Name | Should -Be $assetName
            # }

            # It 'Get-GitHubReleaseAsset - Gets a specific asset by name from a tag' {
            #     $release = Get-GitHubRelease -Owner $Owner -Repository $repo
            #     $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
            #     $assetName = $assets[0].Name
            #     $asset = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -Tag $release.Tag -Name $assetName
            #     LogGroup 'Release asset by name from tag' {
            #         Write-Host ($asset | Format-List -Property * | Out-String)
            #     }
            #     $asset | Should -Not -BeNullOrEmpty
            #     $asset.Name | Should -Be $assetName
            # }

            # It 'Update-GitHubReleaseAsset - Updates a release asset' {
            #     $release = Get-GitHubRelease -Owner $Owner -Repository $repo
            #     $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
            #     $newLabel = 'Updated test asset'
            #     $asset = Update-GitHubReleaseAsset -Owner $Owner -Repository $repo -ID $assets[0].ID -Label $newLabel
            #     LogGroup 'Updated asset' {
            #         Write-Host ($asset | Format-List -Property * | Out-String)
            #     }
            #     $asset | Should -Not -BeNullOrEmpty
            #     $asset.Label | Should -Be $newLabel
            # }

            # It 'Remove-GitHubReleaseAsset - Removes a release asset' {
            #     $release = Get-GitHubRelease -Owner $Owner -Repository $repo
            #     $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
            #     $assetID = $assets[0].ID
            #     Remove-GitHubReleaseAsset -Owner $Owner -Repository $repo -ID $assetID -Confirm:$false
            #     $updatedAssets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
            #     $remainingAsset = $updatedAssets | Where-Object { $_.ID -eq $assetID }
            #     $remainingAsset | Should -BeNullOrEmpty
            # }
        }
    }
}
