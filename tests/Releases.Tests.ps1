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

    Get-Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
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

        Get-Context 'Releases' -Skip:($OwnerType -eq 'repository') {
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
            }

            It 'New-GitHubRelease - Creates a new release with a pre-release' {
                $release = New-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.1' -Prerelease
                LogGroup 'Release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
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
                $release.Latest | Should -Be $true
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
                $release.Latest | Should -Be $false
                $release.Draft | Should -Be $true
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
                $release.Latest | Should -Be $false
                $release.Draft | Should -Be $false
                $release.Prerelease | Should -Be $false
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

            It 'Update-GitHubRelease - Updates a release' {
                $release = Update-GitHubRelease -Owner $Owner -Repository $repo -Tag 'v1.3' -Name 'Updated Release' -Notes 'Updated release notes'
                LogGroup 'Updated release' {
                    Write-Host ($release | Format-List -Property * | Out-String)
                }
                $release | Should -Not -BeNullOrEmpty
                $release.Name | Should -Be 'Updated Release'
                $release.Notes | Should -Be 'Updated release notes'
                $release.Tag | Should -Be 'v1.3'
                $release.Latest | Should -Be $true
                $release.Draft | Should -Be $false
                $release.Prerelease | Should -Be $false
            }
        }
    }
}
