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
                LogGroup 'Context - Installation' {
                    $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                    Write-Host ($context | Format-List | Out-String)
                }
            }
            $repoName = "$testName-$os-$TokenType"
            $varName = "$testName`_$os`_$TokenType"
            $variablePrefix = "$varName`_"
            $environmentName = "$testName-$os-$TokenType"

            if ($Type -ne 'GitHub Actions') {
                LogGroup "Repository - [$repoName]" {
                    Get-GitHubRepository -Owner $Owner | Where-Object { $_.name -like "$repoName*" } | Remove-GitHubRepository -Confirm:$false
                    switch ($OwnerType) {
                        'user' {
                            $repo = New-GitHubRepository -Name $repoName -AllowSquashMerge
                        }
                        'organization' {
                            $repo = New-GitHubRepository -Owner $owner -Name $repoName -AllowSquashMerge
                            $repo2 = New-GitHubRepository -Owner $owner -Name "$repoName-2" -AllowSquashMerge
                            $repo3 = New-GitHubRepository -Owner $owner -Name "$repoName-3" -AllowSquashMerge
                        }
                    }
                    Write-Host ($repo | Format-List | Out-String)
                    Write-Host ($repo2 | Format-List | Out-String)
                    Write-Host ($repo3 | Format-List | Out-String)
                }
            }

            if ($OwnerType -eq 'organization') {
                LogGroup "Org variable - [$varName]" {
                    $params = @{
                        Owner                = $owner
                        Name                 = $varName
                        Value                = 'organization'
                        Visibility           = 'selected'
                        SelectedRepositories = $repo.id
                    }
                    $result = Set-GitHubVariable @params
                    Write-Host ($result | Select-Object * | Format-Table | Out-String)
                }
            }
        }

        AfterAll {
            if ($Type -ne 'GitHub Actions') {
                Remove-GitHubRepository -Owner $owner -Name $repoName -Confirm:$false
            }
            if ($OwnerType -eq 'organization') {
                Get-GitHubVariable -Owner $owner | Remove-GitHubVariable
                Remove-GitHubRepository -Owner $owner -Name "$repoName-2" -Confirm:$false
                Remove-GitHubRepository -Owner $owner -Name "$repoName-3" -Confirm:$false
            }
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }

        # Tests for IAT UAT and PAT goes here
        Context 'Organization' -Skip:($OwnerType -ne 'organization') {
            BeforeAll {
                $scope = @{
                    Owner = $owner
                }
            }
            It 'Set-GitHubVariable - should ensure existance of a organization variable' {
                $name = "$variablePrefix`TestVariable"
                LogGroup "Variable - [$name]" {
                    $param = @{
                        Name       = $name
                        Value      = 'TestValue1234'
                        Visibility = 'private'
                    }
                    $result = Set-GitHubVariable @param @scope
                    Write-Host ($result | Select-Object * | Format-List | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubVariable]
                $result.Name | Should -Be $name
                $result.Value | Should -Be 'TestValue1234'
                $result.Visibility | Should -Be 'private'
            }

            It 'Set-GitHubVariable - should update an existing organization variable' {
                $name = "$variablePrefix`TestVariable"
                LogGroup "Variable - [$name]" {
                    $param = @{
                        Name       = $name
                        Value      = 'TestValue123456789'
                        Visibility = 'all'
                    }
                    $result = Set-GitHubVariable @param @scope
                    Write-Host ($result | Select-Object * | Format-List | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubVariable]
                $result.Name | Should -Be $name
                $result.Value | Should -Be 'TestValue123456789'
                $result.Visibility | Should -Be 'all'
            }

            It 'Update-GitHubVariable - should update an existing organization variable' {
                $name = "$variablePrefix`TestVariable"
                LogGroup "Variable - [$name]" {
                    $param = @{
                        Name  = $name
                        Value = 'TestValue1234'
                    }
                    $result = Update-GitHubVariable @param @scope -PassThru
                    Write-Host ($result | Select-Object * | Format-List | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubVariable]
                $result.Name | Should -Be $name
                $result.Value | Should -Be 'TestValue1234'
                $result.Visibility | Should -Be 'all'
            }

            It 'New-GitHubVariable - should create a new organization variable' {
                $name = "$variablePrefix`TestVariable2"
                LogGroup "Variable - [$name]" {
                    $param = @{
                        Name  = $name
                        Value = 'TestValue123'
                    }
                    $result = New-GitHubVariable @param @scope
                    Write-Host ($result | Select-Object * | Format-List | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                # $result | Should -BeOfType [GitHubVariable]
                $result.Name | Should -Be $name
                $result.Value | Should -Be 'TestValue123'
                $result.Visibility | Should -Be 'private'
            }

            It 'New-GitHubVariable - should throw if creating an organization variable that exists' {
                $name = "$variablePrefix`TestVariable2"
                LogGroup "Variable - [$name]" {
                    $param = @{
                        Name  = $name
                        Value = 'TestValue123'
                    }
                    {
                        $result = New-GitHubVariable @param @scope
                        Write-Host ($result | Select-Object * | Format-List | Out-String)
                    } | Should -Throw
                }
            }

            It 'Get-GitHubVariable' {
                $result = Get-GitHubVariable @scope -Name "$variablePrefix*"
                LogGroup 'Variables' {
                    Write-Host "$($result | Select-Object * | Format-List | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Remove-GitHubVariable' {
                LogGroup 'Before remove' {
                    $before = Get-GitHubVariable @scope -Name "$variablePrefix*"
                    Write-Host "$($before | Format-List | Out-String)"
                }
                LogGroup 'Remove' {
                    $before | Remove-GitHubVariable
                }
                LogGroup 'After remove' {
                    $after = Get-GitHubVariable @scope -Name "$variablePrefix*"
                    Write-Host "$($after | Format-List | Out-String)"
                }
                $after.Count | Should -Be 0
            }

            Context 'SelectedRepository' {
                It 'Get-GitHubVariableSelectedRepository - gets a list of selected repositories' {
                    $result = Get-GitHubVariableSelectedRepository -Owner $owner -Name $varName
                    LogGroup "SelectedRepositories - [$varName]" {
                        Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                    $result[0] | Should -BeOfType [GitHubRepository]
                    $result | Should -HaveCount 1
                }
                It 'Add-GitHubVariableSelectedRepository - adds a repository to the list of selected repositories' {
                    { Add-GitHubVariableSelectedRepository -Owner $owner -Name $varName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Add-GitHubVariableSelectedRepository - adds a repository to the list of selected repositories - idempotency test' {
                    { Add-GitHubVariableSelectedRepository -Owner $owner -Name $varName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Add-GitHubVariableSelectedRepository - adds a repository to the list of selected repositories using pipeline' {
                    LogGroup 'Repo3' {
                        Write-Host "$($repo3 | Format-List | Out-String)"
                    }
                    { $repo3 | Add-GitHubVariableSelectedRepository -Owner $owner -Name $varName } | Should -Not -Throw
                }
                It 'Get-GitHubVariableSelectedRepository - gets 3 repositories' {
                    $result = Get-GitHubVariableSelectedRepository -Owner $owner -Name $varName
                    LogGroup "SelectedRepositories - [$varName]" {
                        Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                    $result[0] | Should -BeOfType [GitHubRepository]
                    $result | Should -HaveCount 3
                }
                It 'Remove-GitHubVariableSelectedRepository - removes a repository from the list of selected repositories' {
                    { Remove-GitHubVariableSelectedRepository -Owner $owner -Name $varName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Remove-GitHubVariableSelectedRepository - removes a repository from the list of selected repositories - idempotency test' {
                    { Remove-GitHubVariableSelectedRepository -Owner $owner -Name $varName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Remove-GitHubVariableSelectedRepository - removes a repository from the list of selected repositories using pipeline' {
                    LogGroup 'Repo3' {
                        Write-Host "$($repo3 | Format-List | Out-String)"
                    }
                    { $repo3 | Remove-GitHubVariableSelectedRepository -Owner $owner -Name $varName } | Should -Not -Throw
                }
                It 'Get-GitHubVariableSelectedRepository - gets 1 repository' {
                    $result = Get-GitHubVariableSelectedRepository -Owner $owner -Name $varName
                    LogGroup "SelectedRepositories - [$varName]" {
                        Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                    $result[0] | Should -BeOfType [GitHubRepository]
                    $result | Should -HaveCount 1
                }
                It 'Set-GitHubVariableSelectedRepository - should set the selected repositories for the variable' {
                    { Set-GitHubVariableSelectedRepository -Owner $owner -Name $varName -RepositoryID $repo.id, $repo2.id, $repo3.id } |
                        Should -Not -Throw
                }
                It 'Set-GitHubVariableSelectedRepository - should set the selected repositories for the variable - idempotency test' {
                    { Set-GitHubVariableSelectedRepository -Owner $owner -Name $varName -RepositoryID $repo.id, $repo2.id, $repo3.id } |
                        Should -Not -Throw
                }
                It 'Get-GitHubVariableSelectedRepository - gets 3 repository' {
                    $result = Get-GitHubVariableSelectedRepository -Owner $owner -Name $varName
                    LogGroup "SelectedRepositories - [$varName]" {
                        Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                    $result[0] | Should -BeOfType [GitHubRepository]
                    $result | Should -HaveCount 3
                }
            }
        }

        Context 'Repository' -Skip:($Type -eq 'GitHub Actions') {
            BeforeAll {
                $scope = @{
                    Owner      = $owner
                    Repository = $repoName
                }
                Set-GitHubVariable @scope -Name $varName -Value 'repository'
            }
            It 'Set-GitHubVariable' {
                $param = @{
                    Name  = "$variablePrefix`TestVariable"
                    Value = 'TestValue'
                }
                $result = Set-GitHubVariable @param @scope
                $result = Set-GitHubVariable @param @scope
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Update-GitHubVariable' {
                $param = @{
                    Name  = "$variablePrefix`TestVariable"
                    Value = 'TestValue1234'
                }
                $result = Update-GitHubVariable @param @scope -PassThru
                $result | Should -Not -BeNullOrEmpty
            }

            It 'New-GitHubVariable' {
                $param = @{
                    Name  = "$variablePrefix`TestVariable2"
                    Value = 'TestValue123'
                }
                $result = New-GitHubVariable @param @scope
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Get-GitHubVariable' {
                $result = Get-GitHubVariable @scope -Name "*$os*"
                LogGroup 'Variables' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Get-GitHubVariable -IncludeInherited' {
                $result = Get-GitHubVariable @scope -Name "*$os*" -IncludeInherited
                LogGroup 'Variables' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Remove-GitHubVariable' {
                $before = Get-GitHubVariable @scope -Name "*$os*"
                LogGroup 'Variables - Before' {
                    Write-Host "$($before | Format-Table | Out-String)"
                }
                $before | Remove-GitHubVariable
                $after = Get-GitHubVariable @scope -Name "*$os*"
                LogGroup 'Variables -After' {
                    Write-Host "$($after | Format-Table | Out-String)"
                }
                $after.Count | Should -Be 0
            }
        }

        Context 'Environment' -Skip:($Type -eq 'GitHub Actions') {
            BeforeAll {
                $scope = @{
                    Owner      = $owner
                    Repository = $repoName
                }
                Set-GitHubVariable @scope -Name $varName -Value 'repository'
                $scope = @{
                    Owner       = $owner
                    Repository  = $repoName
                    Environment = $environmentName
                }
                Set-GitHubEnvironment -Owner $owner -Repository $repoName -Name $environmentName
                Set-GitHubVariable @scope -Name $varName -Value 'environment'
            }
            It 'Set-GitHubVariable' {
                $param = @{
                    Name  = "$variablePrefix`TestVariable"
                    Value = 'TestValue'
                }
                $result = Set-GitHubVariable @param @scope
                $result = Set-GitHubVariable @param @scope
                LogGroup 'Variables' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Update-GitHubVariable' {
                $param = @{
                    Name  = "$variablePrefix`TestVariable"
                    Value = 'TestValue1234'
                }
                $result = Update-GitHubVariable @param @scope -PassThru
                LogGroup 'Variables' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'New-GitHubVariable' {
                $param = @{
                    Name  = "$variablePrefix`TestVariable2"
                    Value = 'TestValue123'
                }
                $result = New-GitHubVariable @param @scope
                LogGroup 'Variables' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Get-GitHubVariable' {
                $result = Get-GitHubVariable @scope -Name "*$os*"
                LogGroup 'Variables' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Get-GitHubVariable -IncludeInherited' {
                $result = Get-GitHubVariable @scope -Name "*$os*" -IncludeInherited
                LogGroup 'Variables' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Remove-GitHubVariable' {
                LogGroup 'Variables - Before' {
                    $before = Get-GitHubVariable @scope -Name "*$os*"
                    Write-Host "$($before | Format-Table | Out-String)"
                }
                $before | Remove-GitHubVariable
                LogGroup 'Variables - After' {
                    $after = Get-GitHubVariable @scope -Name "*$os*"
                    Write-Host "$($after | Format-Table | Out-String)"
                }
                $after.Count | Should -Be 0
            }
        }
    }
}
