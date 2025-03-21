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

Describe 'Template' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
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
        if ($Type -eq 'GitHub Actions') {}

        # Tests for IAT UAT and PAT goes here

        It "Get-GitHubRepository - Gets the authenticated user's repositories (USER_FG_PAT)" {
            $repo = Get-GitHubRepository
            LogGroup 'Repository' {
                Write-Host ($repo | Format-Table | Out-String)
            }
            $repo | Should -Not -BeNullOrEmpty
        }
        It "Get-GitHubRepository - Gets the authenticated user's public repositories (USER_FG_PAT)" {
            $repo = Get-GitHubRepository -Type 'public'
            LogGroup 'Repository' {
                Write-Host ($repo | Format-Table | Out-String)
            }
            $repo | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRepository - Gets the public repos where the authenticated user is owner (USER_FG_PAT)' {
            $repo = Get-GitHubRepository -Visibility 'public' -Affiliation 'owner'
            LogGroup 'Repository' {
                Write-Host ($repo | Format-Table | Out-String)
            }
            $repo | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRepository - Gets a specific repository (USER_FG_PAT)' {
            $repo = Get-GitHubRepository -Owner 'PSModule' -Name 'GitHub'
            LogGroup 'Repository' {
                Write-Host ($repo | Format-Table | Out-String)
            }
            $repo | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRepository - Gets all repositories from a organization (USER_FG_PAT)' {
            $repo = Get-GitHubRepository -Owner 'PSModule'
            LogGroup 'Repository' {
                Write-Host ($repo | Format-Table | Out-String)
            }
            $repo | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRepository - Gets all repositories from a user (USER_FG_PAT)' {
            $repo = Get-GitHubRepository -Username 'MariusStorhaug'
            LogGroup 'Repository' {
                Write-Host ($repo | Format-Table | Out-String)
            }
            $repo | Should -Not -BeNullOrEmpty
        }
    }
}

AfterAll {
    Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
}
