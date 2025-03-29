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
    $testName = 'RepositoryTest'
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
            # Tests for APP goes here
            if ($AuthType -eq 'APP') {
                It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                    $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                    LogGroup 'Context' {
                        Write-Host ($context | Format-List | Out-String)
                    }
                }
            }
            $repoName = "$testName-$os-$TokenType"
        }
        AfterAll {
            if ($OwnerType -ne 'repository') {
                Remove-GitHubRepository -Owner $Owner -Name $repoName -Confirm:$false
            }
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }


        if ($Type -ne 'GitHub Actions') {
            # Tests for IAT UAT and PAT goes here
            It 'New-GitHubRepository - Creates a new repository' {
                if ($OwnerType -eq 'user') {
                    New-GitHubRepository -Name $repoName -AllowSquashMerge
                } else {
                    New-GitHubRepository -Owner $Owner -Name $repoName -AllowSquashMerge
                }
            }
            if ($OwnerType -eq 'user') {
                It "Get-GitHubRepository - Gets the authenticated user's repositories" {
                    $repos = Get-GitHubRepository
                    LogGroup 'Repositories' {
                        Write-Host ($repos | Format-List | Out-String)
                    }
                    $repos | Should -Not -BeNullOrEmpty
                }
                It "Get-GitHubRepository - Gets the authenticated user's public repositories" {
                    $repos = Get-GitHubRepository -Type 'public'
                    LogGroup 'Repositories' {
                        Write-Host ($repos | Format-List | Out-String)
                    }
                    $repos | Should -Not -BeNullOrEmpty
                }
                It 'Get-GitHubRepository - Gets the public repos where the authenticated user is owner' {
                    $repos = Get-GitHubRepository -Visibility 'public' -Affiliation 'owner'
                    LogGroup 'Repositories' {
                        Write-Host ($repos | Format-List | Out-String)
                    }
                    $repos | Should -Not -BeNullOrEmpty
                }
            }
            It 'Get-GitHubRepository - Gets a specific repository' {
                $repo = Get-GitHubRepository -Owner 'PSModule' -Name 'GitHub'
                LogGroup 'Repository' {
                    Write-Host ($repo | Format-List | Out-String)
                }
                $repo | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubRepository - Gets all repositories from a organization' {
                $repos = Get-GitHubRepository -Owner 'PSModule'
                LogGroup 'Repositories' {
                    Write-Host ($repos | Format-List | Out-String)
                }
                $repos | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubRepository - Gets all repositories from a user' {
                $repos = Get-GitHubRepository -Username 'MariusStorhaug'
                LogGroup 'Repositories' {
                    Write-Host ($repos | Format-List | Out-String)
                }
                $repos | Should -Not -BeNullOrEmpty
            }
            It 'Remove-GitHubRepository - Removes all repositories' {
                LogGroup 'Repositories' {
                    $repos = Get-GitHubRepository -Owner $Owner -Name $repoName
                    Write-Host ($repos | Format-List | Out-String)
                }
                Remove-GitHubRepository -Owner $Owner -Name $repoName -Confirm:$false
            }
            It 'Get-GitHubRepository - Gets none repositories after removal' {
                if ($OwnerType -eq 'user') {
                    $repos = Get-GitHubRepository -Username $Owner | Where-Object { $_.name -like "$repoName*" }
                } else {
                    $repos = Get-GitHubRepository -Owner $Owner | Where-Object { $_.name -like "$repoName*" }
                }
                LogGroup 'Repositories' {
                    Write-Host ($repos | Format-List | Out-String)
                }
                $repos | Should -BeNullOrEmpty
            }
        }
    }
}
