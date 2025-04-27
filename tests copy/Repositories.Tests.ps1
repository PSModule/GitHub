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
    $testName = 'RepositoriesTests'
    $os = $env:RUNNER_OS
    $guid = [guid]::NewGuid().ToString()
}

Describe 'Repositories' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            if ($AuthType -eq 'APP') {
                LogGroup 'Context - Installation' {
                    $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                    Write-Host ($context | Format-List | Out-String)
                }
            }
            $repoPrefix = "$testName-$os-$TokenType"
            $repoName = "$repoPrefix-$guid"
        }

        AfterAll {
            switch ($OwnerType) {
                'user' {
                    Get-GitHubRepository | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                }
                'organization' {
                    Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoPrefix*" } |
                        Remove-GitHubRepository -Confirm:$false
                }
            }
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }

        # Tests for IAT UAT and PAT goes here
        It 'New-GitHubRepository - Creates a new repository' -Skip:($OwnerType -eq 'repository') {
            switch ($OwnerType) {
                'user' {
                    New-GitHubRepository -Name $repoName -AllowSquashMerge
                }
                'organization' {
                    New-GitHubRepository -Organization $owner -Name $repoName -AllowSquashMerge
                }
            }
        }
        It "Get-GitHubRepository - Gets the authenticated user's repositories" -Skip:($OwnerType -ne 'user') {
            $repos = Get-GitHubRepository
            LogGroup 'Repositories' {
                Write-Host ($repos | Format-Table | Out-String)
            }
            $repos | Should -Not -BeNullOrEmpty
        }
        It "Get-GitHubRepository - Gets the authenticated user's public repositories" -Skip:($OwnerType -ne 'user') {
            $repos = Get-GitHubRepository -Type 'public'
            LogGroup 'Repositories' {
                Write-Host ($repos | Format-Table | Out-String)
            }
            $repos | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRepository - Gets the public repos where the authenticated user is owner' -Skip:($OwnerType -ne 'user') {
            $repos = Get-GitHubRepository -Visibility 'public'
            LogGroup 'Repositories' {
                Write-Host ($repos | Format-Table | Out-String)
            }
            $repos | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRepository - Gets a specific repository' -Skip:($OwnerType -eq 'repository') {
            $repo = Get-GitHubRepository -Organization 'PSModule' -Name 'GitHub'
            LogGroup 'Repository' {
                Write-Host ($repo | Format-List | Out-String)
            }
            $repo | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRepository - Gets all repositories from a organization' -Skip:($OwnerType -eq 'repository') {
            $repos = Get-GitHubRepository -Organization 'PSModule'
            LogGroup 'Repositories' {
                Write-Host ($repos | Format-Table | Out-String)
            }
            $repos | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRepository - Gets all repositories from a user' -Skip:($OwnerType -eq 'repository') {
            $repos = Get-GitHubRepository -Username 'MariusStorhaug'
            LogGroup 'Repositories' {
                Write-Host ($repos | Format-Table | Out-String)
            }
            $repos | Should -Not -BeNullOrEmpty
        }
        It 'Remove-GitHubRepository - Removes all repositories' -Skip:($OwnerType -eq 'repository') {
            LogGroup 'Repositories' {
                $repos = Get-GitHubRepository -Organization $Owner -Name $repoName
                Write-Host ($repos | Format-List | Out-String)
            }
            Remove-GitHubRepository -Owner $Owner -Name $repoName -Confirm:$false
        }
        It 'Get-GitHubRepository - Gets none repositories after removal' -Skip:($OwnerType -eq 'repository') {
            if ($OwnerType -eq 'user') {
                $repos = Get-GitHubRepository -Username $Owner | Where-Object { $_.name -like "$repoName*" }
            } else {
                $repos = Get-GitHubRepository -Organization $Owner | Where-Object { $_.name -like "$repoName*" }
            }
            LogGroup 'Repositories' {
                Write-Host ($repos | Format-List | Out-String)
            }
            $repos | Should -BeNullOrEmpty
        }
    }
}
