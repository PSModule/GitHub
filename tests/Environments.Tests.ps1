#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax - known issue.'
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

Describe 'Environments' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            $guid = [guid]::NewGuid().ToString()
            $repo = "$repoSuffix-$guid"
        }

        AfterAll {
            Remove-GitHubRepository -Owner $owner -Name $repo -Confirm:$false
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
            It 'Prep - New-GitHubRepository' {
                if ($type -eq 'a user') {
                    New-GitHubRepository -Name $repo -AllowSquashMerge
                } else {
                    New-GitHubRepository -Owner $owner -Name $repo -AllowSquashMerge
                }
            }
            It 'Get-GitHubEnvironment - should return an empty list when no environments exist' {
                $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
                LogGroup "Environment" {
                    Write-Host ($result | Format-Table | Out-String)
                }
                $result | Should -BeNullOrEmpty
            }
            It 'Get-GitHubEnvironment - should return null when retrieving a non-existent environment' {
                $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
                LogGroup 'Environment' {
                    Write-Host ($result | Format-Table | Out-String)
                }
                $result | Should -BeNullOrEmpty
            }
            It 'Set-GitHubEnvironment - should successfully create an environment with a wait timer of 10' {
                $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -WaitTimer 10
                LogGroup 'Environment' {
                    Write-Host ($result | Format-List | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubEnvironment]
                $result.Name | Should -Be $environmentName
                $result.ProtectionRules.wait_timer | Should -Be 10
            }
            It 'Get-GitHubEnvironment - should retrieve the environment that was created' {
                $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
                LogGroup 'Environment' {
                    Write-Host ($result | Format-List | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result.Name | Should -Be $environmentName
            }
            It 'Set-GitHubEnvironment - should successfully create an environment with a slash in its name' {
                $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
                LogGroup 'Environment' {
                    Write-Host ($result | Format-List | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result.Name | Should -Be "$environmentName/$os"
            }
            It 'Get-GitHubEnvironment - should retrieve the environment with a slash in its name' {
                $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
                LogGroup 'Environment' {
                    Write-Host ($result | Format-Table | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result.Name | Should -Be "$environmentName/$os"
            }
            It 'Remove-GitHubEnvironment - should delete the environment with a slash in its name without errors' {
                {
                    Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os" | Remove-GitHubEnvironment -Confirm:$false
                } | Should -Not -Throw
            }
            It 'Get-GitHubEnvironment - should return null when retrieving the deleted environment with a slash in its name' {
                $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
                LogGroup 'Environment' {
                    Write-Host ($result | Format-Table | Out-String)
                }
                $result | Should -BeNullOrEmpty
            }
            It 'Get-GitHubEnvironment - should list one remaining environment' {
                $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
                LogGroup 'Environment' {
                    Write-Host ($result | Format-Table | Out-String)
                }
                $result.Count | Should -Be 1
            }
            It 'Remove-GitHubEnvironment - should delete the remaining environment without errors' {
                { Remove-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -Confirm:$false } | Should -Not -Throw
            }
            It 'Get-GitHubEnvironment - should return null when retrieving an environment that does not exist' {
                $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
                LogGroup 'Environment' {
                    Write-Host ($result | Format-Table | Out-String)
                }
                $result | Should -BeNullOrEmpty
            }
        }
    }
}

AfterAll {
    Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
}
