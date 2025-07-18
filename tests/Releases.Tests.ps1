﻿#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

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
                Name      = $repoName
                Context   = $context
                AddReadme = $true
                License   = 'mit'
                Gitignore = 'VisualStudio'
            }
            switch ($OwnerType) {
                'user' {
                    Get-GitHubRepository | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                    $repo = New-GitHubRepository @params
                }
                'organization' {
                    Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                    $repo = New-GitHubRepository @params -Organization $owner
                }
            }
            LogGroup "Repository - [$repoName]" {
                Write-Host ($repo | Select-Object * | Out-String)
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
            Write-Host ('-' * 60)
        }

        Context 'Releases' -Skip:($OwnerType -in ('repository', 'enterprise')) {
            It 'New-GitHubRelease - Creates a new release' {
                $release = New-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.0' -Latest
                LogGroup 'Release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
                $release | Should -BeOfType 'GitHubRelease'
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
                $release | Should -BeOfType 'GitHubRelease'
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
                $release | Should -BeOfType 'GitHubRelease'
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
                $release | Should -BeOfType 'GitHubRelease'
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
                $release | Should -BeOfType 'GitHubRelease'
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
                $release | Should -BeOfType 'GitHubRelease'
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
                $release | Should -BeOfType 'GitHubRelease'
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
                $release | Should -BeOfType 'GitHubRelease'
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
                $release | Should -BeOfType 'GitHubRelease'
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
                $release | Should -BeOfType 'GitHubRelease'
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

            It 'New-GitHubReleaseNote - Generates release notes' {
                $notes = New-GitHubReleaseNote -Owner $Owner -Repository $repo -Tag 'v1.4'
                LogGroup 'Generated release notes' {
                    Write-Host ($notes | Format-List -Property * | Out-String)
                }
                $notes | Should -Not -BeNullOrEmpty
                $notes.Name | Should -Not -BeNullOrEmpty
                $notes.Notes | Should -Not -BeNullOrEmpty
            }

            It 'New-GitHubReleaseNote - Generates release notes with custom parameters' {
                $releaseTag = 'v1.4'
                $previousTag = 'v1.3'
                $notes = New-GitHubReleaseNote -Owner $Owner -Repository $repo -Tag $releaseTag -PreviousTag $previousTag -Target 'main'
                LogGroup 'Generated release notes with parameters' {
                    Write-Host ($notes | Format-List -Property * | Out-String)
                }
                $notes | Should -Not -BeNullOrEmpty
                $notes.Name | Should -Not -BeNullOrEmpty
                $notes.Notes | Should -Not -BeNullOrEmpty
                $notes.Notes | Should -Match $releaseTag
            }
        }
        Context 'Release Assets' -Skip:($OwnerType -in ('repository', 'enterprise')) {
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
                $zipFileName = "$testFolderName.zip"
                $zipFilePath = Join-Path -Path $PSScriptRoot -ChildPath $zipFileName
                Compress-Archive -Path "$testFolderPath\*" -DestinationPath $zipFilePath -Force
                $testFiles['ZipFile'] = @{
                    Name        = $zipFileName
                    Path        = $zipFilePath
                    ContentType = 'application/zip'
                }
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo
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

                $downloadPath = Join-Path -Path $PSScriptRoot -ChildPath "Downloaded-$($testFiles.TextFile.Name)"
                Invoke-WebRequest -Uri $asset.Url -OutFile $downloadPath -RetryIntervalSec 5 -MaximumRetryCount 5
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

                $downloadPath = Join-Path -Path $PSScriptRoot -ChildPath "Downloaded-$customName"
                Invoke-WebRequest -Uri $asset.Url -OutFile $downloadPath -RetryIntervalSec 5 -MaximumRetryCount 5
                (Get-Content -Path $downloadPath -Raw) | Should -Match '# Test Documentation'
            }

            It 'Add-GitHubReleaseAsset - Adds a folder as a zipped asset to a release' {
                $label = 'Test Files Collection'
                $asset = $release | Add-GitHubReleaseAsset -Label $label -Path $testFiles.ZipFile.Path
                LogGroup 'Added zip asset' {
                    Write-Host ($asset | Format-List -Property * | Out-String)
                }
                $asset | Should -Not -BeNullOrEmpty
                $asset | Should -BeOfType 'GitHubReleaseAsset'
                $asset.Name | Should -Be $testFiles.ZipFile.Name
                $asset.Label | Should -Be $label
                $asset.ContentType | Should -Be $testFiles.ZipFile.ContentType
                $asset.Size | Should -BeGreaterThan 0

                $downloadPath = Join-Path -Path $PSScriptRoot -ChildPath "Downloaded-$($testFiles.ZipFile.Name)"
                Invoke-WebRequest -Uri $asset.Url -OutFile $downloadPath -RetryIntervalSec 5 -MaximumRetryCount 5
                Test-Path -Path $downloadPath | Should -BeTrue
            }

            It 'Add-GitHubReleaseAsset - Adds multiple files from a folder to a release' {
                $folderName = "FolderAssetTest-$testFolderGuid"
                $folderPath = Join-Path -Path $PSScriptRoot -ChildPath $folderName
                New-Item -Path $folderPath -ItemType Directory -Force

                $fileContents = @{
                    'config.json' = '{"name": "Test Config", "version": "1.0.0"}'
                    'readme.md'   = '# Test Folder\nThis is a test folder for uploading to a GitHub release.'
                    'data.txt'    = 'This is some test data'
                }

                foreach ($file in $fileContents.GetEnumerator()) {
                    $filePath = Join-Path -Path $folderPath -ChildPath $file.Key
                    Set-Content -Path $filePath -Value $file.Value
                }

                $asset = $release | Add-GitHubReleaseAsset -Path $folderPath -Label 'Folder Asset Test'

                LogGroup 'Added folder asset' {
                    Write-Host ($asset | Format-List -Property * | Out-String)
                }

                $asset | Should -Not -BeNullOrEmpty
                $asset | Should -BeOfType 'GitHubReleaseAsset'
                $asset.Name | Should -Be $folderName
                $asset.Label | Should -Be 'Folder Asset Test'
                $asset.ContentType | Should -Be 'application/zip'
                $asset.Size | Should -BeGreaterThan 0

                $downloadPath = Join-Path -Path $PSScriptRoot -ChildPath "Downloaded-$folderName.zip"
                Invoke-WebRequest -Uri $asset.Url -OutFile $downloadPath -RetryIntervalSec 5 -MaximumRetryCount 5

                $extractPath = Join-Path -Path $PSScriptRoot -ChildPath "Extract-$folderName"
                New-Item -Path $extractPath -ItemType Directory -Force
                Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

                foreach ($file in $fileContents.GetEnumerator()) {
                    $extractedFilePath = Join-Path -Path $extractPath -ChildPath $file.Key
                    Test-Path -Path $extractedFilePath | Should -BeTrue
                    Get-Content -Path $extractedFilePath | Should -Be $file.Value
                }
            }

            It 'Get-GitHubReleaseAsset - Gets all assets from a release ID' {
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo
                $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
                LogGroup 'Release assets by release ID' {
                    Write-Host ($assets | Format-List -Property * | Out-String)
                }
                $assets | Should -Not -BeNullOrEmpty
                $assets.Count | Should -Be 4
                $assets | Should -BeOfType 'GitHubReleaseAsset'
            }

            It 'Get-GitHubReleaseAsset - Gets all assets from the latest release' {
                $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo
                LogGroup 'Release assets from latest release' {
                    Write-Host ($assets | Format-List -Property * | Out-String)
                }
                $assets | Should -Not -BeNullOrEmpty
                $assets | Should -BeOfType 'GitHubReleaseAsset'
            }

            It 'Get-GitHubReleaseAsset - Gets a specific asset by ID' {
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo
                $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
                $asset = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ID $assets[0].ID
                LogGroup 'Release asset by asset ID' {
                    Write-Host ($asset | Format-List -Property * | Out-String)
                }
                $asset | Should -Not -BeNullOrEmpty
                $asset | Should -BeOfType 'GitHubReleaseAsset'
                $asset.ID | Should -Be $assets[0].ID
            }

            It 'Get-GitHubReleaseAsset - Gets a specific asset by name from a release ID' {
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo
                $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
                $assetName = $assets[0].Name
                $asset = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID -Name $assetName
                LogGroup 'Release asset by name from release ID' {
                    Write-Host ($asset | Format-List -Property * | Out-String)
                }
                $asset | Should -Not -BeNullOrEmpty
                $asset | Should -BeOfType 'GitHubReleaseAsset'
                $asset.Name | Should -Be $assetName
            }

            It 'Get-GitHubReleaseAsset - Gets a specific asset by name from a tag' {
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo
                $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
                $assetName = $assets[0].Name
                $asset = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -Tag $release.Tag -Name $assetName
                LogGroup 'Release asset by name from tag' {
                    Write-Host ($asset | Format-List -Property * | Out-String)
                }
                $asset | Should -Not -BeNullOrEmpty
                $asset | Should -BeOfType 'GitHubReleaseAsset'
                $asset.Name | Should -Be $assetName
            }

            It 'Update-GitHubReleaseAsset - Updates a release asset' {
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo
                $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
                $newLabel = 'Updated test asset'
                $asset = Update-GitHubReleaseAsset -Owner $Owner -Repository $repo -ID $assets[0].ID -Label $newLabel
                LogGroup 'Updated asset' {
                    Write-Host ($asset | Format-List -Property * | Out-String)
                }
                $asset | Should -Not -BeNullOrEmpty
                $asset | Should -BeOfType 'GitHubReleaseAsset'
                $asset.Label | Should -Be $newLabel
            }

            It 'Remove-GitHubReleaseAsset - Removes a release asset' {
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo
                $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
                $assetID = $assets[0].ID
                Remove-GitHubReleaseAsset -Owner $Owner -Repository $repo -ID $assetID -Confirm:$false
                $updatedAssets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
                $remainingAsset = $updatedAssets | Where-Object { $_.ID -eq $assetID }
                $remainingAsset | Should -BeNullOrEmpty
            }

            It 'Save-GitHubReleaseAsset - Downloads a release asset by ID' {
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo
                $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
                $downloadPath = Join-Path -Path $PSScriptRoot -ChildPath "DownloadTest-$testFolderGuid"
                New-Item -Path $downloadPath -ItemType Directory -Force | Out-Null

                $downloadedFile = Save-GitHubReleaseAsset -Owner $Owner -Repository $repo -ID $assets[0].ID -Path $downloadPath -PassThru
                LogGroup 'Downloaded Asset' {
                    Write-Host ($downloadedFile | Format-List | Out-String)
                }

                $downloadedFile | Should -Not -BeNullOrEmpty
                Test-Path -Path $downloadedFile.FullName | Should -BeTrue
                $downloadedFile.Name | Should -Be $assets[0].Name
            }

            It 'Save-GitHubReleaseAsset - Downloads a release asset by name from a tag' {
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo
                $assets = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID
                $assetName = $assets[1].Name
                $downloadPath = Join-Path -Path $PSScriptRoot -ChildPath "DownloadByName-$testFolderGuid"
                New-Item -Path $downloadPath -ItemType Directory -Force | Out-Null

                $downloadedFile = Save-GitHubReleaseAsset -Owner $Owner -Repository $repo -Tag $release.Tag -Name $assetName -Path $downloadPath -PassThru
                LogGroup 'Downloaded Asset by Name' {
                    Write-Host ($downloadedFile | Format-List | Out-String)
                }

                $downloadedFile | Should -Not -BeNullOrEmpty
                Test-Path -Path $downloadedFile.FullName | Should -BeTrue
                $downloadedFile.Name | Should -Be $assetName
            }

            It 'Save-GitHubReleaseAsset - Downloads and extracts a ZIP release asset' {
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo
                $zipAsset = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID |
                    Where-Object { $_.Name -like '*.zip' } |
                    Select-Object -First 1

                if ($zipAsset) {
                    $extractPath = Join-Path -Path $PSScriptRoot -ChildPath "ExtractTest-$testFolderGuid"
                    New-Item -Path $extractPath -ItemType Directory -Force | Out-Null

                    $extractedItems = Save-GitHubReleaseAsset -Owner $Owner -Repository $repo -ID $zipAsset.ID -Path $extractPath -Expand -PassThru
                    LogGroup 'Extracted ZIP Asset' {
                        Write-Host ($extractedItems | Format-Table | Out-String)
                    }

                    $extractedItems | Should -Not -BeNullOrEmpty
                    Test-Path -Path $extractPath | Should -BeTrue
                    Test-Path -Path (Join-Path -Path $extractPath -ChildPath $zipAsset.Name) | Should -BeFalse
                    (Get-ChildItem -Path $extractPath -Recurse).Count | Should -BeGreaterThan 0
                } else {
                    Set-ItResult -Inconclusive -Because 'No ZIP asset found for testing extraction'
                }
            }

            It 'Save-GitHubReleaseAsset - Uses pipeline input from Get-GitHubReleaseAsset' {
                $release = Get-GitHubRelease -Owner $Owner -Repository $repo
                $asset = Get-GitHubReleaseAsset -Owner $Owner -Repository $repo -ReleaseID $release.ID |
                    Select-Object -First 1

                $pipelinePath = Join-Path -Path $PSScriptRoot -ChildPath "PipelineTest-$testFolderGuid"
                New-Item -Path $pipelinePath -ItemType Directory -Force | Out-Null

                $downloadedFile = $asset | Save-GitHubReleaseAsset -Path $pipelinePath -PassThru
                LogGroup 'Downloaded Asset via Pipeline' {
                    Write-Host ($downloadedFile | Format-List | Out-String)
                }

                $downloadedFile | Should -Not -BeNullOrEmpty
                Test-Path -Path $downloadedFile.FullName | Should -BeTrue
                $downloadedFile.Name | Should -Be $asset.Name
            }

            It 'Get-GitHubReleaseAsset - Gets assets from release using pipeline' {
                $assets = Get-GitHubRelease -Owner ryanoasis -Repository nerd-fonts | Get-GitHubReleaseAsset
                LogGroup 'Release assets from pipeline' {
                    Write-Host ($assets | Format-List -Property * | Out-String)
                }
                $assets | Should -Not -BeNullOrEmpty
                $assets.Count | Should -BeGreaterThan 0
                foreach ($asset in $assets) {
                    $asset | Should -BeOfType [GitHubReleaseAsset]
                    $asset.ID | Should -Not -BeNullOrEmpty
                    $asset.NodeID | Should -Not -BeNullOrEmpty
                    $asset.Url | Should -Not -BeNullOrEmpty
                    $asset.Name | Should -Not -BeNullOrEmpty
                    # $asset.Label | Should -Not -BeNullOrEmpty - Label is optional and may not be set
                    $asset.State | Should -Be 'uploaded'
                    $asset.ContentType | Should -Not -BeNullOrEmpty
                    $asset.Size | Should -BeGreaterOrEqual 0
                    $asset.Downloads | Should -BeGreaterOrEqual 0
                    $asset.CreatedAt | Should -Not -BeNullOrEmpty
                    $asset.CreatedAt | Should -BeOfType 'DateTime'
                    $asset.UpdatedAt | Should -Not -BeNullOrEmpty
                    $asset.UpdatedAt | Should -BeOfType 'DateTime'
                    $asset.UploadedBy | Should -Not -BeNullOrEmpty
                    $asset.UploadedBy | Should -BeOfType 'GitHubUser'
                }
            }
        }
    }
}
