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
    Justification = 'Outputs into logs from the tests.'
)]
[CmdletBinding()]
param()

BeforeAll {
    $testName = 'VariableTest'
    $os = $env:RUNNER_OS
}

Describe 'Variables' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            $repoName = "$testName-$os-$TokenType"
            $varName = "$testName`_$os`_$TokenType"
            $variablePrefix = "$varName`_"
            $environmentName = "$testName-$os-$TokenType"
        }
        AfterAll {
            Remove-GitHubRepository -Owner $owner -Name $repoName -Confirm:$false
            if ($OwnerType -eq 'organization') {
                Get-GitHubVariable -Owner $owner -Name "*$os*" | Remove-GitHubVariable
            }
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

        Context 'Prep' {
            BeforeAll {
                if ($OwnerType -eq 'organization') {
                    $repo = New-GitHubRepository -Owner $owner -Name $repoName -AllowSquashMerge
                    Set-GitHubVariable -Owner $owner -Name $varName -Value 'organization' -Visibility selected -SelectedRepositories $repo.id
                } else {
                    $repo = New-GitHubRepository -Name $repoName -AllowSquashMerge
                }
                LogGroup 'Repository' {
                    Write-Host ($repo | Format-List | Out-String)
                }
            }
        }

        # # Tests for IAT UAT and PAT goes here
        # Context 'Organization' -Skip:($TokenType -in 'GITHUB_TOKEN') {

        #     It 'Set-GitHubVariable' {
        #         $param = @{
        #             Name  = "$variablePrefix`TestVariable"
        #             Value = 'TestValue'
        #         }
        #         $result = Set-GitHubVariable @param @scope
        #         $result = Set-GitHubVariable @param @scope
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'Update-GitHubVariable' {
        #         $param = @{
        #             Name       = "$variablePrefix`TestVariable"
        #             Value      = 'TestValue1234'
        #             Visibility = 'all'
        #         }
        #         $result = Update-GitHubVariable @param @scope -PassThru
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'New-GitHubVariable' {
        #         $param = @{
        #             Name  = "$variablePrefix`TestVariable2"
        #             Value = 'TestValue123'
        #         }
        #         $result = New-GitHubVariable @param @scope
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'Get-GitHubVariable' {
        #         $result = Get-GitHubVariable @scope -Name "*$os*"
        #         Write-Host "$($result | Format-Table | Out-String)"
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'Get-GitHubVariable -All' {
        #         $result = Get-GitHubVariable @scope -Name "*$os*" -All
        #         Write-Host "$($result | Format-Table | Out-String)"
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'Remove-GitHubVariable' {
        #         $before = Get-GitHubVariable @scope -Name "*$os*"
        #         Write-Host "$($before | Format-Table | Out-String)"
        #         $before | Remove-GitHubVariable
        #         $after = Get-GitHubVariable @scope -Name "*$os*"
        #         Write-Host "$($after | Format-Table | Out-String)"
        #         $after.Count | Should -Be 0
        #     }
        # }
        # Context 'Repository' {
        #     BeforeAll {
        #         $scope = @{
        #             Owner      = $owner
        #             Repository = $repoName
        #         }
        #         Set-GitHubVariable @scope -Name $varName -Value 'repository'
        #     }
        #     It 'Set-GitHubVariable' {
        #         $param = @{
        #             Name  = "$variablePrefix`TestVariable"
        #             Value = 'TestValue'
        #         }
        #         $result = Set-GitHubVariable @param @scope
        #         $result = Set-GitHubVariable @param @scope
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'Update-GitHubVariable' {
        #         $param = @{
        #             Name  = "$variablePrefix`TestVariable"
        #             Value = 'TestValue1234'
        #         }
        #         $result = Update-GitHubVariable @param @scope -PassThru
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'New-GitHubVariable' {
        #         $param = @{
        #             Name  = "$variablePrefix`TestVariable2"
        #             Value = 'TestValue123'
        #         }
        #         $result = New-GitHubVariable @param @scope
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'Get-GitHubVariable' {
        #         $result = Get-GitHubVariable @scope -Name "*$os*"
        #         Write-Host "$($result | Format-Table | Out-String)"
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'Get-GitHubVariable -All' {
        #         $result = Get-GitHubVariable @scope -Name "*$os*" -All
        #         Write-Host "$($result | Format-Table | Out-String)"
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'Remove-GitHubVariable' {
        #         $before = Get-GitHubVariable @scope -Name "*$os*"
        #         Write-Host "$($before | Format-Table | Out-String)"
        #         $before | Remove-GitHubVariable
        #         $after = Get-GitHubVariable @scope -Name "*$os*"
        #         Write-Host "$($after | Format-Table | Out-String)"
        #         $after.Count | Should -Be 0
        #     }
        # }
        # Context 'Environment' {
        #     BeforeAll {
        #         $scope = @{
        #             Owner       = $owner
        #             Repository  = $repoName
        #             Environment = $environmentName
        #         }
        #         Set-GitHubEnvironment -Owner $owner -Repository $repoName -Name $environmentName
        #         Set-GitHubVariable @scope -Name $varName -Value 'environment'
        #     }
        #     It 'Set-GitHubVariable' {
        #         $param = @{
        #             Name  = "$variablePrefix`TestVariable"
        #             Value = 'TestValue'
        #         }
        #         $result = Set-GitHubVariable @param @scope
        #         $result = Set-GitHubVariable @param @scope
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'Update-GitHubVariable' {
        #         $param = @{
        #             Name  = "$variablePrefix`TestVariable"
        #             Value = 'TestValue1234'
        #         }
        #         $result = Update-GitHubVariable @param @scope -PassThru
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'New-GitHubVariable' {
        #         $param = @{
        #             Name  = "$variablePrefix`TestVariable2"
        #             Value = 'TestValue123'
        #         }
        #         $result = New-GitHubVariable @param @scope
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'Get-GitHubVariable' {
        #         $result = Get-GitHubVariable @scope -Name "*$os*"
        #         Write-Host "$($result | Format-Table | Out-String)"
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'Get-GitHubVariable -All' {
        #         $result = Get-GitHubVariable @scope -Name "*$os*" -All
        #         Write-Host "$($result | Format-Table | Out-String)"
        #         $result | Should -Not -BeNullOrEmpty
        #     }

        #     It 'Remove-GitHubVariable' {
        #         $before = Get-GitHubVariable @scope -Name "*$os*"
        #         Write-Host "$($before | Format-Table | Out-String)"
        #         $before | Remove-GitHubVariable
        #         $after = Get-GitHubVariable @scope -Name "*$os*"
        #         Write-Host "$($after | Format-Table | Out-String)"
        #         $after.Count | Should -Be 0
        #     }
        # }
    }
}
