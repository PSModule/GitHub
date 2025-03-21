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
[CmdletBinding()]
param()

BeforeAll {
    $repoSuffix = 'EnvironmentTest'
    $environmentName = 'production'
    $os = $env:RUNNER_OS
}
Describe 'Template' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }

        # Tests for APP goes here
        if ($AuthType -eq 'APP') {
            It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                LogGroup 'Context' {
                    Write-Host ($context | Format-List | Out-String)
                }
            }
        }

        # Tests for runners goes here
        if ($Type -ne 'GitHub Actions') {

            # Tests for IAT UAT and PAT goes here
            It 'New-GitHubRepository - Creates a new repository' {
                $guid = [guid]::NewGuid().ToString()
                $repo = "$repoSuffix-$os-$guid"
                if ($OwnerType -eq 'user') {
                    New-GitHubRepository -Name $repo -AllowSquashMerge
                } else {
                    New-GitHubRepository -Owner $Owner -Name $repo -AllowSquashMerge
                }
            }
            It "Get-GitHubRepository - Gets the authenticated user's repositories" {
                $repo = Get-GitHubRepository
                LogGroup 'Repository' {
                    Write-Host ($repo | Format-Table | Out-String)
                }
                $repo | Should -Not -BeNullOrEmpty
            }
            It "Get-GitHubRepository - Gets the authenticated user's public repositories" {
                $repo = Get-GitHubRepository -Type 'public'
                LogGroup 'Repository' {
                    Write-Host ($repo | Format-Table | Out-String)
                }
                $repo | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubRepository - Gets the public repos where the authenticated user is owner' {
                $repo = Get-GitHubRepository -Visibility 'public' -Affiliation 'owner'
                LogGroup 'Repository' {
                    Write-Host ($repo | Format-Table | Out-String)
                }
                $repo | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubRepository - Gets a specific repository' {
                $repo = Get-GitHubRepository -Owner 'PSModule' -Name 'GitHub'
                LogGroup 'Repository' {
                    Write-Host ($repo | Format-Table | Out-String)
                }
                $repo | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubRepository - Gets all repositories from a organization' {
                $repo = Get-GitHubRepository -Owner 'PSModule'
                LogGroup 'Repository' {
                    Write-Host ($repo | Format-Table | Out-String)
                }
                $repo | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubRepository - Gets all repositories from a user' {
                $repo = Get-GitHubRepository -Username 'MariusStorhaug'
                LogGroup 'Repository' {
                    Write-Host ($repo | Format-Table | Out-String)
                }
                $repo | Should -Not -BeNullOrEmpty
            }
            It 'Remove-GitHubRepository - Removes all repositories' {
                Remove-GitHubRepository -Owner $owner -Name $repo -Confirm:$false
            }
        }
    }
}
