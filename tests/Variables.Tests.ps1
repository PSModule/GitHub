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
    $testName = 'VariablesTests'
    $os = $env:RUNNER_OS
    $guid = [guid]::NewGuid().ToString() -replace '-', '_'
}

Describe 'Variables' {
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
            $variablePrefix = "$testName`_$os`_$TokenType"
            $variableName = "$variablePrefix`_$guid"
            $orgVariableName = "$variableName`_ORG"
            $environmentName = "$testName-$os-$TokenType-$guid"

            switch ($OwnerType) {
                'user' {
                    Get-GitHubRepository | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                    $repo = New-GitHubRepository -Name "$repoName-1"
                    $repo2 = New-GitHubRepository -Name "$repoName-2"
                    $repo3 = New-GitHubRepository -Name "$repoName-3"
                }
                'organization' {
                    Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                    Get-GitHubVariable -Owner $Owner | Where-Object { $_.Name -like "$variablePrefix*" } | Remove-GitHubVariable -Confirm:$false
                    $repo = New-GitHubRepository -Organization $owner -Name "$repoName-1"
                    $repo2 = New-GitHubRepository -Organization $owner -Name "$repoName-2"
                    $repo3 = New-GitHubRepository -Organization $owner -Name "$repoName-3"
                    LogGroup "Org variable - [$orgVariableName]" {
                        $params = @{
                            Owner                = $owner
                            Name                 = $orgVariableName
                            Value                = 'organization'
                            Visibility           = 'selected'
                            SelectedRepositories = $repo.id
                        }
                        $orgVariable = Set-GitHubVariable @params -Debug
                        Write-Host ($orgVariable | Select-Object * | Out-String)
                    }
                }
            }
            LogGroup "Repository - [$repoName]" {
                Write-Host ($repo | Select-Object * | Out-String)
                Write-Host ($repo2 | Select-Object * | Out-String)
                Write-Host ($repo3 | Select-Object * | Out-String)
            }
        }

        AfterAll {
            switch ($OwnerType) {
                'user' {
                    Get-GitHubRepository | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                }
                'organization' {
                    $variablesToRemove = Get-GitHubVariable -Owner $owner | Where-Object { $_.Name -like "$variablePrefix*" }
                    LogGroup 'Secrets to remove' {
                        Write-Host "$($variablesToRemove | Format-List | Out-String)"
                    }
                    $variablesToRemove | Remove-GitHubVariable
                    LogGroup 'Repos to remove' {
                        $reposToRemove = Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoPrefix*" }
                        Write-Host "$($reposToRemove | Format-List | Out-String)"
                        $reposToRemove | Remove-GitHubRepository -Confirm:$false
                    }
                }
            }
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            Write-Host ('-' * 60)
        }

        Context 'Organization' -Skip:($OwnerType -ne 'organization') {
            BeforeAll {
                $scope = @{
                    Owner = $owner
                }
            }
            It 'Set-GitHubVariable - should ensure existance of a organization variable' {
                $name = "$variableName`TestVariable"
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
                $result.Scope | Should -Be 'Organization'
                $result.Visibility | Should -Be 'private'
            }

            It 'Set-GitHubVariable - should update an existing organization variable' {
                $name = "$variableName`TestVariable"
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
                $result.Scope | Should -Be 'Organization'
                $result.Visibility | Should -Be 'all'
            }

            It 'Update-GitHubVariable - should update an existing organization variable' {
                $name = "$variableName`TestVariable"
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
                $result.Scope | Should -Be 'Organization'
                $result.Visibility | Should -Be 'all'
            }

            It 'New-GitHubVariable - should create a new organization variable' {
                $name = "$variableName`TestVariable2"
                LogGroup "Variable - [$name]" {
                    $param = @{
                        Name  = $name
                        Value = 'TestValue123'
                    }
                    $result = New-GitHubVariable @param @scope
                    Write-Host ($result | Select-Object * | Format-List | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubVariable]
                $result.Name | Should -Be $name
                $result.Value | Should -Be 'TestValue123'
                $result.Scope | Should -Be 'Organization'
                $result.Visibility | Should -Be 'private'
            }

            It 'New-GitHubVariable - should throw if creating an organization variable that exists' {
                $name = "$variableName`TestVariable2"
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
                $result = Get-GitHubVariable @scope -Name "$variableName*"
                LogGroup 'Variables' {
                    Write-Host "$($result | Select-Object * | Format-List | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Export-GitHubVariable' {
                Get-GitHubVariable @scope -IncludeInherited | Export-GitHubVariable
                $result = Get-ChildItem -Path env: | Where-Object { $_.Name -like "$variableName*" }
                LogGroup 'Variables' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Remove-GitHubVariable by name parameter' {
                $testVarName = "$variableName`RemoveByName"
                LogGroup 'Create variable for removal test' {
                    $createResult = Set-GitHubVariable @scope -Name $testVarName -Value 'TestForRemoval'
                    Write-Host "$($createResult | Format-List | Out-String)"
                }
                LogGroup 'Verify variable exists' {
                    $before = Get-GitHubVariable @scope -Name $testVarName
                    Write-Host "$($before | Format-List | Out-String)"
                    $before | Should -Not -BeNullOrEmpty
                }
                LogGroup 'Remove by name' {
                    Remove-GitHubVariable @scope -Name $testVarName
                }
                LogGroup 'Verify variable removed' {
                    $after = Get-GitHubVariable @scope -Name $testVarName
                    Write-Host "$($after | Format-List | Out-String)"
                    $after | Should -BeNullOrEmpty
                }
            }

            It 'Remove-GitHubVariable' {
                $testVarName = "$variableName`TestVariable*"
                LogGroup 'Before remove' {
                    $before = Get-GitHubVariable @scope -Name $testVarName
                    Write-Host "$($before | Format-List | Out-String)"
                }
                LogGroup 'Remove' {
                    $before | Remove-GitHubVariable
                }
                LogGroup 'After remove' {
                    $after = Get-GitHubVariable @scope -Name $testVarName
                    Write-Host "$($after | Format-List | Out-String)"
                }
                $after.Count | Should -Be 0
            }

            Context 'SelectedRepository' -Tag 'Flaky' {
                It 'Get-GitHubVariableSelectedRepository - gets a list of selected repositories' {
                    LogGroup "SelectedRepositories - [$orgVariableName]" {
                        $result = Get-GitHubVariableSelectedRepository -Owner $owner -Name $orgVariableName
                        Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                    $result[0] | Should -BeOfType [GitHubRepository]
                    $result | Should -HaveCount 1
                }
                It 'Add-GitHubVariableSelectedRepository - adds a repository to the list of selected repositories' {
                    { Add-GitHubVariableSelectedRepository -Owner $owner -Name $orgVariableName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Add-GitHubVariableSelectedRepository - adds a repository to the list of selected repositories - idempotency test' {
                    { Add-GitHubVariableSelectedRepository -Owner $owner -Name $orgVariableName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Add-GitHubVariableSelectedRepository - adds a repository to the list of selected repositories using pipeline' {
                    LogGroup 'Repo3' {
                        Write-Host "$($repo3 | Format-List | Out-String)"
                    }
                    { $repo3 | Add-GitHubVariableSelectedRepository -Owner $owner -Name $orgVariableName } | Should -Not -Throw
                }
                It 'Get-GitHubVariableSelectedRepository - gets 3 repositories' {
                    LogGroup "SelectedRepositories - [$orgVariableName]" {
                        $result = Get-GitHubVariableSelectedRepository -Owner $owner -Name $orgVariableName
                        Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                    $result[0] | Should -BeOfType [GitHubRepository]
                    $result | Should -HaveCount 3
                }
                It 'Remove-GitHubVariableSelectedRepository - removes a repository from the list of selected repositories' {
                    { Remove-GitHubVariableSelectedRepository -Owner $owner -Name $orgVariableName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Remove-GitHubVariableSelectedRepository - removes a repository from the list of selected repositories - idempotency test' {
                    { Remove-GitHubVariableSelectedRepository -Owner $owner -Name $orgVariableName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Remove-GitHubVariableSelectedRepository - removes a repository from the list of selected repositories using pipeline' {
                    LogGroup 'Repo3' {
                        Write-Host "$($repo3 | Format-List | Out-String)"
                    }
                    { $repo3 | Remove-GitHubVariableSelectedRepository -Owner $owner -Name $orgVariableName } | Should -Not -Throw
                }
                It 'Get-GitHubVariableSelectedRepository - gets 1 repository' {
                    LogGroup "SelectedRepositories - [$orgVariableName]" {
                        $result = Get-GitHubVariableSelectedRepository -Owner $owner -Name $orgVariableName
                        Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                    $result[0] | Should -BeOfType [GitHubRepository]
                    $result | Should -HaveCount 1
                }
                It 'Set-GitHubVariableSelectedRepository - should set the selected repositories for the variable' {
                    { Set-GitHubVariableSelectedRepository -Owner $owner -Name $orgVariableName -RepositoryID $repo.id, $repo2.id, $repo3.id } |
                        Should -Not -Throw
                }
                It 'Set-GitHubVariableSelectedRepository - should set the selected repositories for the variable - idempotency test' {
                    { Set-GitHubVariableSelectedRepository -Owner $owner -Name $orgVariableName -RepositoryID $repo.id, $repo2.id, $repo3.id } |
                        Should -Not -Throw
                }
                It 'Get-GitHubVariableSelectedRepository - gets 3 repository' {
                    $result = Get-GitHubVariableSelectedRepository -Owner $owner -Name $orgVariableName
                    LogGroup "SelectedRepositories - [$orgVariableName]" {
                        Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                    $result[0] | Should -BeOfType [GitHubRepository]
                    $result | Should -HaveCount 3
                }
            }
        }

        Context 'Repository' -Skip:($OwnerType -eq 'repository') {
            BeforeAll {
                $scope = @{
                    Owner      = $owner
                    Repository = $repo
                }
                Set-GitHubVariable @scope -Name $orgVariableName -Value 'repository'
            }
            It 'Set-GitHubVariable' {
                $name = "$variableName`TestVariable"
                $value = 'TestValue'
                $param = @{
                    Name  = $name
                    Value = $value
                }
                $result = Set-GitHubVariable @param @scope
                $result = Set-GitHubVariable @param @scope
                LogGroup 'Variable' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubVariable]
                $result.Name | Should -Be $name
                $result.Value | Should -Be $value
                $result.Scope | Should -Be 'Repository'
                $result.Visibility | Should -BeNullOrEmpty
            }

            It 'Update-GitHubVariable' {
                $param = @{
                    Name  = "$variableName`TestVariable"
                    Value = 'TestValue1234'
                }
                $result = Update-GitHubVariable @param @scope -PassThru
                LogGroup 'Variable' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'New-GitHubVariable' {
                $name = "$variableName`TestVariable2"
                $value = 'TestValue123'
                $param = @{
                    Name  = $name
                    Value = $value
                }
                $result = New-GitHubVariable @param @scope
                LogGroup 'Variable' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubVariable]
                $result.Name | Should -Be $name
                $result.Value | Should -Be $value
                $result.Scope | Should -Be 'Repository'
                $result.Visibility | Should -BeNullOrEmpty
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

            It 'Export-GitHubVariable' {
                Get-GitHubVariable @scope -IncludeInherited | Export-GitHubVariable
                $result = Get-ChildItem -Path env: | Where-Object { $_.Name -like "$variableName*" }
                LogGroup 'Variables' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Remove-GitHubVariable by name parameter' {
                $testVarName = "$variableName`RemoveByName"
                LogGroup 'Create variable for removal test' {
                    $createResult = Set-GitHubVariable @scope -Name $testVarName -Value 'TestForRemoval'
                    Write-Host "$($createResult | Format-List | Out-String)"
                }
                LogGroup 'Verify variable exists' {
                    $before = Get-GitHubVariable @scope -Name $testVarName
                    Write-Host "$($before | Format-List | Out-String)"
                    $before | Should -Not -BeNullOrEmpty
                }
                LogGroup 'Remove by name' {
                    Remove-GitHubVariable @scope -Name $testVarName
                }
                LogGroup 'Verify variable removed' {
                    $after = Get-GitHubVariable @scope -Name $testVarName
                    Write-Host "$($after | Format-List | Out-String)"
                    $after | Should -BeNullOrEmpty
                }
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

        Context 'Environment' -Skip:($OwnerType -eq 'repository') {
            BeforeAll {
                $scope = @{
                    Owner      = $owner
                    Repository = $repo
                }
                Set-GitHubVariable @scope -Name $orgVariableName -Value 'repository'
                $scope = @{
                    Owner       = $owner
                    Repository  = $repo
                    Environment = $environmentName
                }
                Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
                Set-GitHubVariable @scope -Name $orgVariableName -Value 'environment'
            }
            It 'Set-GitHubVariable' {
                $name = "$variableName`TestVariable"
                $value = 'TestValue'
                $param = @{
                    Name  = $name
                    Value = $value
                }
                $result = Set-GitHubVariable @param @scope
                $result = Set-GitHubVariable @param @scope
                LogGroup 'Variable' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubVariable]
                $result.Name | Should -Be $name
                $result.Value | Should -Be $value
                $result.Scope | Should -Be 'Environment'
                $result.Visibility | Should -BeNullOrEmpty
            }

            It 'Update-GitHubVariable' {
                $param = @{
                    Name  = "$variableName`TestVariable"
                    Value = 'TestValue1234'
                }
                $result = Update-GitHubVariable @param @scope -PassThru
                LogGroup 'Variables' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'New-GitHubVariable' {
                $name = "$variableName`TestVariable2"
                $value = 'TestValue123'
                $param = @{
                    Name  = $name
                    Value = $value
                }
                $result = Set-GitHubVariable @param @scope
                $result = Set-GitHubVariable @param @scope
                LogGroup 'Variables' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubVariable]
                $result.Name | Should -Be $name
                $result.Value | Should -Be $value
                $result.Scope | Should -Be 'Environment'
                $result.Visibility | Should -BeNullOrEmpty
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

            It 'Export-GitHubVariable' {
                Get-GitHubVariable @scope -IncludeInherited | Export-GitHubVariable
                $result = Get-ChildItem -Path env: | Where-Object { $_.Name -like "$variableName*" }
                LogGroup 'Variables' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Remove-GitHubVariable by name parameter' {
                $testVarName = "$variableName`RemoveByName"
                LogGroup 'Create variable for removal test' {
                    $createResult = Set-GitHubVariable @scope -Name $testVarName -Value 'TestForRemoval'
                    Write-Host "$($createResult | Format-List | Out-String)"
                }
                LogGroup 'Verify variable exists' {
                    $before = Get-GitHubVariable @scope -Name $testVarName
                    Write-Host "$($before | Format-List | Out-String)"
                    $before | Should -Not -BeNullOrEmpty
                }
                LogGroup 'Remove by name' {
                    Remove-GitHubVariable @scope -Name $testVarName
                }
                LogGroup 'Verify variable removed' {
                    $after = Get-GitHubVariable @scope -Name $testVarName
                    Write-Host "$($after | Format-List | Out-String)"
                    $after | Should -BeNullOrEmpty
                }
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
