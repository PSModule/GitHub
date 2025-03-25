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
    $testName = 'VariableTest'
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
            if ($AuthType -eq 'APP') {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                LogGroup 'Context - Installation' {
                    Write-Host ($context | Format-List | Out-String)
                }
            }
            $repoName = "$testName-$guid"
            $repoName = "$testName-$os-$TokenType"
            $varName = "$testName`_$os`_$TokenType"
            $variablePrefix = "$varName`_"
            $environmentName = "$testName-$os-$TokenType"

            if ($Type -ne 'GitHub Actions') {
                if ($OwnerType -eq 'user') {
                    $repo = New-GitHubRepository -Name $repoName -AllowSquashMerge
                } else {
                    $repo = New-GitHubRepository -Owner $owner -Name $repoName -AllowSquashMerge
                }
                LogGroup 'Repository' {
                    Write-Host ($repo | Format-List | Out-String)
                }
            }
        }

        AfterAll {
            if ($Type -ne 'GitHub Actions') {
                Remove-GitHubRepository -Owner $owner -Name $repoName -Confirm:$false
            }
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }

        It 'Set-GitHubVariable - should ensure existance of a organization variable' -Skip:($OwnerType -ne 'organization') {
            Write-Debug "Test to see if Debug is working"
            Write-Verbose 'Test to see if Verbose is working'
            Write-Verbose 'Test to see if Verbose is working with switch' -Verbose
            Set-GitHubVariable -Owner $owner -Name $varName -Value 'organization' -Visibility selected -SelectedRepositories $repo.id
            LogGroup 'Variable' {
                Write-Host ($result | Format-Table | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [GitHubVariable]
            $result.Name | Should -Be "$os-$repo"
        }

        # # Tests for runners goes here
        # if ($Type -ne 'GitHub Actions') {
        #     # Tests for IAT UAT and PAT goes here
        #     It 'Prep - New-GitHubRepository' {
        #         if ($OwnerType -eq 'user') {
        #             New-GitHubRepository -Name $repo -AllowSquashMerge
        #         } else {
        #             New-GitHubRepository -Owner $owner -Name $repo -AllowSquashMerge
        #         }
        #     }
        #     It 'Get-GitHubEnvironment - should return an empty list when no environments exist' {
        #         $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
        #         LogGroup 'Environment' {
        #             Write-Host ($result | Format-Table | Out-String)
        #         }
        #         $result | Should -BeNullOrEmpty
        #     }
        #     It 'Get-GitHubEnvironment - should return null when retrieving a non-existent environment' {
        #         $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
        #         LogGroup 'Environment' {
        #             Write-Host ($result | Format-Table | Out-String)
        #         }
        #         $result | Should -BeNullOrEmpty
        #     }
        #     It 'Set-GitHubEnvironment - should successfully create an environment with a wait timer of 10' {
        #         $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -WaitTimer 10
        #         LogGroup 'Environment' {
        #             Write-Host ($result | Format-List | Out-String)
        #         }
        #         $result | Should -Not -BeNullOrEmpty
        #         $result | Should -BeOfType [GitHubEnvironment]
        #         $result.Name | Should -Be $environmentName
        #         $result.ProtectionRules.wait_timer | Should -Be 10
        #     }
        #     It 'Get-GitHubEnvironment - should retrieve the environment that was created' {
        #         $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
        #         LogGroup 'Environment' {
        #             Write-Host ($result | Format-List | Out-String)
        #         }
        #         $result | Should -Not -BeNullOrEmpty
        #         $result.Name | Should -Be $environmentName
        #     }
        #     It 'Set-GitHubEnvironment - should successfully create an environment with a slash in its name' {
        #         $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
        #         LogGroup 'Environment' {
        #             Write-Host ($result | Format-List | Out-String)
        #         }
        #         $result | Should -Not -BeNullOrEmpty
        #         $result.Name | Should -Be "$environmentName/$os"
        #     }
        #     It 'Get-GitHubEnvironment - should retrieve the environment with a slash in its name' {
        #         $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
        #         LogGroup 'Environment' {
        #             Write-Host ($result | Format-Table | Out-String)
        #         }
        #         $result | Should -Not -BeNullOrEmpty
        #         $result.Name | Should -Be "$environmentName/$os"
        #     }
        #     It 'Remove-GitHubEnvironment - should delete the environment with a slash in its name without errors' {
        #         {
        #             Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os" | Remove-GitHubEnvironment -Confirm:$false
        #         } | Should -Not -Throw
        #     }
        #     It 'Get-GitHubEnvironment - should return null when retrieving the deleted environment with a slash in its name' {
        #         $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
        #         LogGroup 'Environment' {
        #             Write-Host ($result | Format-Table | Out-String)
        #         }
        #         $result | Should -BeNullOrEmpty
        #     }
        #     It 'Get-GitHubEnvironment - should list one remaining environment' {
        #         $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
        #         LogGroup 'Environment' {
        #             Write-Host ($result | Format-Table | Out-String)
        #         }
        #         $result.Count | Should -Be 1
        #     }
        #     It 'Remove-GitHubEnvironment - should delete the remaining environment without errors' {
        #         { Remove-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -Confirm:$false } | Should -Not -Throw
        #     }
        #     It 'Get-GitHubEnvironment - should return null when retrieving an environment that does not exist' {
        #         $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
        #         LogGroup 'Environment' {
        #             Write-Host ($result | Format-Table | Out-String)
        #         }
        #         $result | Should -BeNullOrEmpty
        #     }
        # }

        It 'Remove-GitHubVariable - should delete the organization variable' -Skip:($OwnerType -ne 'organization') {
            $result = Get-GitHubVariable -Owner $owner -Name "$varName*"
            LogGroup 'Variable' {
                Write-Host ($result | Format-Table | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
            $result | Remove-GitHubVariable
        }
    }
}
