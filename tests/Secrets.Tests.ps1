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
    $testName = 'SecretsTests'
    $os = $env:RUNNER_OS
    $guid = [guid]::NewGuid().ToString() -replace '-', '_'
}

Describe 'Secrets' {
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
            $secretPrefix = "$testName`_$os`_$TokenType"
            $secretName = "$secretPrefix`_$guid"
            $orgSecretName = "$secretName`_ORG"
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
                    Get-GitHubSecret -Owner $Owner | Where-Object { $_.Name -like "$secretPrefix*" } | Remove-GitHubSecret -Confirm:$false
                    $repo = New-GitHubRepository -Organization $owner -Name "$repoName-1"
                    $repo2 = New-GitHubRepository -Organization $owner -Name "$repoName-2"
                    $repo3 = New-GitHubRepository -Organization $owner -Name "$repoName-3"
                    LogGroup "Org secret - [$orgSecretName]" {
                        $params = @{
                            Owner                = $owner
                            Name                 = $orgSecretName
                            Value                = 'organization'
                            Visibility           = 'selected'
                            SelectedRepositories = $repo.id
                        }

                        $orgSecret += Set-GitHubSecret @params -Debug
                        Write-Host ($orgSecret | Select-Object * | Out-String)
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
                    LogGroup 'Secrets to remove' {
                        $orgSecrets = Get-GitHubSecret -Owner $owner | Where-Object { $_.Name -like "$secretName*" }
                        Write-Host "$($orgSecrets | Format-List | Out-String)"
                        $orgSecrets | Remove-GitHubSecret
                    }
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

        Context 'User' -Skip:($OwnerType -ne 'user') {
            Context 'PublicKey' {
                It 'Get-GitHubPublicKey - Action' {
                    { Get-GitHubPublicKey } | Should -Throw
                }

                It 'Get-GitHubPublicKey - Codespaces' {
                    $result = Get-GitHubPublicKey -Type codespaces
                    LogGroup 'PublicKey - Codespaces' {
                        Write-Host "$($result | Select-Object * | Format-Table -AutoSize | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                }
            }
        }

        Context 'Organization' -Skip:($OwnerType -ne 'organization') {
            BeforeAll {
                $scope = @{
                    Owner = $owner
                }
                LogGroup 'Organization' {
                    $org = Get-GitHubOrganization -Name $owner
                    Write-Host ($org | Format-List | Out-String)
                }
            }
            Context 'PublicKey' {
                It 'Get-GitHubPublicKey - Action' {
                    $result = Get-GitHubPublicKey @scope
                    LogGroup 'PublicKey' {
                        Write-Host "$($result | Select-Object * | Format-Table -AutoSize | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                }

                It 'Get-GitHubPublicKey - Codespaces' {
                    switch ($org.plan.name) {
                        'free' {
                            { Get-GitHubPublicKey @scope -Type codespaces } | Should -Throw
                        }
                        default {
                            $result = Get-GitHubPublicKey @scope -Type codespaces
                            LogGroup 'PublicKey' {
                                Write-Host "$($result | Select-Object * | Format-Table -AutoSize | Out-String)"
                            }
                            $result | Should -Not -BeNullOrEmpty
                        }
                    }
                }
            }

            It 'Set-GitHubSecret - should ensure existance of a organization secret' {
                $name = "$secretName`_TestSecret"
                LogGroup "Secret - [$name]" {
                    $param = @{
                        Name       = $name
                        Value      = 'TestValue1234'
                        Visibility = 'private'
                    }
                    $result = Set-GitHubSecret @param @scope
                    Write-Host ($result | Select-Object * | Format-List | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubSecret]
                $result.Name | Should -Be $name
                $result.Scope | Should -Be 'Organization'
                $result.Visibility | Should -Be 'private'
            }

            It 'Set-GitHubSecret - should update an existing organization secret' {
                $name = "$secretName`_TestSecret"
                LogGroup "Secret - [$name]" {
                    $param = @{
                        Name       = $name
                        Value      = 'TestValue123456789'
                        Visibility = 'all'
                    }
                    $result = Set-GitHubSecret @param @scope
                    Write-Host ($result | Select-Object * | Format-List | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubSecret]
                $result.Name | Should -Be $name
                $result.Scope | Should -Be 'Organization'
                $result.Visibility | Should -Be 'all'
            }

            It 'Get-GitHubSecret' {
                $result = Get-GitHubSecret @scope -Name "$secretName*"
                LogGroup 'Secrets' {
                    Write-Host "$($result | Select-Object * | Format-List | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Remove-GitHubSecret by name parameter' {
                $testSecretName = "$secretName`RemoveByName"
                LogGroup 'Create secret for removal test' {
                    $createResult = Set-GitHubSecret @scope -Name $testSecretName -Value 'TestForRemoval'
                    Write-Host "$($createResult | Format-List | Out-String)"
                }
                LogGroup 'Verify secret exists' {
                    $before = Get-GitHubSecret @scope -Name $testSecretName
                    Write-Host "$($before | Format-List | Out-String)"
                    $before | Should -Not -BeNullOrEmpty
                }
                LogGroup 'Remove by name' {
                    Remove-GitHubSecret @scope -Name $testSecretName
                }
                LogGroup 'Verify secret removed' {
                    $after = Get-GitHubSecret @scope -Name $testSecretName
                    Write-Host "$($after | Format-List | Out-String)"
                    $after | Should -BeNullOrEmpty
                }
            }

            It 'Remove-GitHubSecret' {
                $testSecretName = "$secretName`TestSecret*"
                LogGroup 'Before remove' {
                    $before = Get-GitHubSecret @scope -Name $testSecretName
                    Write-Host "$($before | Format-List | Out-String)"
                }
                LogGroup 'Remove' {
                    $before | Remove-GitHubSecret
                }
                LogGroup 'After remove' {
                    $after = Get-GitHubSecret @scope -Name $testSecretName
                    Write-Host "$($after | Format-List | Out-String)"
                }
                $after.Count | Should -Be 0
            }

            Context 'SelectedRepository' {
                It 'Get-GitHubSecretSelectedRepository - gets a list of selected repositories' {
                    LogGroup "SelectedRepositories - [$orgSecretName]" {
                        $result = Get-GitHubSecretSelectedRepository -Owner $owner -Name $orgSecretName
                        Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                    $result[0] | Should -BeOfType [GitHubRepository]
                    $result | Should -HaveCount 1
                }
                It 'Add-GitHubSecretSelectedRepository - adds a repository to the list of selected repositories' {
                    { Add-GitHubSecretSelectedRepository -Owner $owner -Name $orgSecretName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Add-GitHubSecretSelectedRepository - adds a repository to the list of selected repositories - idempotency test' {
                    { Add-GitHubSecretSelectedRepository -Owner $owner -Name $orgSecretName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Add-GitHubSecretSelectedRepository - adds a repository to the list of selected repositories using pipeline' {
                    LogGroup 'Repo3' {
                        Write-Host "$($repo3 | Format-List | Out-String)"
                    }
                    { $repo3 | Add-GitHubSecretSelectedRepository -Owner $owner -Name $orgSecretName } | Should -Not -Throw
                }
                It 'Get-GitHubSecretSelectedRepository - gets 3 repositories' {
                    LogGroup "SelectedRepositories - [$orgSecretName]" {
                        $result = Get-GitHubSecretSelectedRepository -Owner $owner -Name $orgSecretName
                        Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                    $result[0] | Should -BeOfType [GitHubRepository]
                    $result | Should -HaveCount 3
                }
                It 'Remove-GitHubSecretSelectedRepository - removes a repository from the list of selected repositories' {
                    { Remove-GitHubSecretSelectedRepository -Owner $owner -Name $orgSecretName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Remove-GitHubSecretSelectedRepository - removes a repository from the list of selected repositories - idempotency test' {
                    { Remove-GitHubSecretSelectedRepository -Owner $owner -Name $orgSecretName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Remove-GitHubSecretSelectedRepository - removes a repository from the list of selected repositories using pipeline' {
                    LogGroup 'Repo3' {
                        Write-Host "$($repo3 | Format-List | Out-String)"
                    }
                    { $repo3 | Remove-GitHubSecretSelectedRepository -Owner $owner -Name $orgSecretName } | Should -Not -Throw
                }
                It 'Get-GitHubSecretSelectedRepository - gets 1 repository' {
                    LogGroup "SelectedRepositories - [$orgSecretName]" {
                        $result = Get-GitHubSecretSelectedRepository -Owner $owner -Name $orgSecretName
                        Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                    $result[0] | Should -BeOfType [GitHubRepository]
                    $result | Should -HaveCount 1
                }
                It 'Set-GitHubSecretSelectedRepository - should set the selected repositories for the secret' {
                    { Set-GitHubSecretSelectedRepository -Owner $owner -Name $orgSecretName -RepositoryID $repo.id, $repo2.id, $repo3.id } |
                        Should -Not -Throw
                }
                It 'Set-GitHubSecretSelectedRepository - should set the selected repositories for the secret - idempotency test' {
                    { Set-GitHubSecretSelectedRepository -Owner $owner -Name $orgSecretName -RepositoryID $repo.id, $repo2.id, $repo3.id } |
                        Should -Not -Throw
                }
                It 'Get-GitHubSecretSelectedRepository - gets 3 repository' {
                    $result = Get-GitHubSecretSelectedRepository -Owner $owner -Name $orgSecretName
                    LogGroup "SelectedRepositories - [$orgSecretName]" {
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
                Set-GitHubSecret @scope -Name $orgSecretName -Value 'repository'
            }

            Context 'PublicKey' {
                It 'Get-GitHubPublicKey - Action' {
                    $result = Get-GitHubPublicKey @scope
                    LogGroup 'PublicKey' {
                        Write-Host "$($result | Select-Object * | Format-Table -AutoSize| Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                }

                It 'Get-GitHubPublicKey - Codespaces' {
                    $result = Get-GitHubPublicKey @scope -Type codespaces
                    LogGroup 'PublicKey' {
                        Write-Host "$($result | Select-Object * | Format-Table -AutoSize | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                }
            }

            It 'Set-GitHubSecret - String' {
                $param = @{
                    Name  = "$secretName`TestSecret"
                    Value = 'TestValue'
                }
                $result = Set-GitHubSecret @param @scope
                $result = Set-GitHubSecret @param @scope
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubSecret]
                $result.Scope | Should -Be 'Repository'
            }

            It 'Set-GitHubSecret - SecureString' {
                $param = @{
                    Name  = "$secretName`TestSecret"
                    Value = ConvertTo-SecureString -String 'TestValue' -AsPlainText
                }
                $result = Set-GitHubSecret @param @scope
                $result = Set-GitHubSecret @param @scope
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubSecret]
                $result.Scope | Should -Be 'Repository'
            }

            It 'Set-GitHubSecret' {
                $param = @{
                    Name  = "$secretName`TestSecret2"
                    Value = 'TestValue123'
                }
                $result = Set-GitHubSecret @param @scope
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubSecret]
                $result.Scope | Should -Be 'Repository'
            }

            It 'Get-GitHubSecret' {
                $result = Get-GitHubSecret @scope -Name "*$os*"
                LogGroup 'Secrets' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Get-GitHubSecret -IncludeInherited' {
                $result = Get-GitHubSecret @scope -Name "*$os*" -IncludeInherited
                LogGroup 'Secrets' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Remove-GitHubSecret by name parameter' {
                $testSecretName = "$secretName`RemoveByName"
                LogGroup 'Create secret for removal test' {
                    $createResult = Set-GitHubSecret @scope -Name $testSecretName -Value 'TestForRemoval'
                    Write-Host "$($createResult | Format-List | Out-String)"
                }
                LogGroup 'Verify secret exists' {
                    $before = Get-GitHubSecret @scope -Name $testSecretName
                    Write-Host "$($before | Format-List | Out-String)"
                    $before | Should -Not -BeNullOrEmpty
                }
                LogGroup 'Remove by name' {
                    Remove-GitHubSecret @scope -Name $testSecretName
                }
                LogGroup 'Verify secret removed' {
                    $after = Get-GitHubSecret @scope -Name $testSecretName
                    Write-Host "$($after | Format-List | Out-String)"
                    $after | Should -BeNullOrEmpty
                }
            }

            It 'Remove-GitHubSecret' {
                $before = Get-GitHubSecret @scope -Name "*$os*"
                LogGroup 'Secrets - Before' {
                    Write-Host "$($before | Format-Table | Out-String)"
                }
                $before | Remove-GitHubSecret
                $after = Get-GitHubSecret @scope -Name "*$os*"
                LogGroup 'Secrets -After' {
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
                Set-GitHubSecret @scope -Name $orgSecretName -Value 'repository'
                $scope = @{
                    Owner       = $owner
                    Repository  = $repo
                    Environment = $environmentName
                }
                Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
                Set-GitHubSecret @scope -Name $orgSecretName -Value 'environment'
            }

            Context 'PublicKey' {
                It 'Get-GitHubPublicKey - Action' {
                    $result = Get-GitHubPublicKey @scope
                    LogGroup 'PublicKey' {
                        Write-Host "$($result | Select-Object * | Format-Table -AutoSize| Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                }

                It 'Get-GitHubPublicKey - Codespaces' {
                    { Get-GitHubPublicKey @scope -Type codespaces } | Should -Throw
                }
            }

            It 'Set-GitHubSecret' {
                $param = @{
                    Name  = "$secretName`TestSecret"
                    Value = 'TestValue'
                }
                $result = Set-GitHubSecret @param @scope
                $result = Set-GitHubSecret @param @scope
                LogGroup 'Secrets' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubSecret]
                $result.Scope | Should -Be 'Environment'
            }

            It 'Set-GitHubSecret' {
                $param = @{
                    Name  = "$secretName`TestSecret2"
                    Value = 'TestValue123'
                }
                $result = Set-GitHubSecret @param @scope
                LogGroup 'Secrets' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubSecret]
                $result.Scope | Should -Be 'Environment'
            }

            It 'Get-GitHubSecret' {
                $result = Get-GitHubSecret @scope -Name "*$os*"
                LogGroup 'Secrets' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Get-GitHubSecret -IncludeInherited' {
                $result = Get-GitHubSecret @scope -Name "*$os*" -IncludeInherited
                LogGroup 'Secrets' {
                    Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Remove-GitHubSecret by name parameter' {
                $testSecretName = "$secretName`RemoveByName"
                LogGroup 'Create secret for removal test' {
                    $createResult = Set-GitHubSecret @scope -Name $testSecretName -Value 'TestForRemoval'
                    Write-Host "$($createResult | Format-List | Out-String)"
                }
                LogGroup 'Verify secret exists' {
                    $before = Get-GitHubSecret @scope -Name $testSecretName
                    Write-Host "$($before | Format-List | Out-String)"
                    $before | Should -Not -BeNullOrEmpty
                }
                LogGroup 'Remove by name' {
                    Remove-GitHubSecret @scope -Name $testSecretName
                }
                LogGroup 'Verify secret removed' {
                    $after = Get-GitHubSecret @scope -Name $testSecretName
                    Write-Host "$($after | Format-List | Out-String)"
                    $after | Should -BeNullOrEmpty
                }
            }

            It 'Remove-GitHubSecret' {
                LogGroup 'Secrets - Before' {
                    $before = Get-GitHubSecret @scope -Name "*$os*"
                    Write-Host "$($before | Format-Table | Out-String)"
                }
                $before | Remove-GitHubSecret
                LogGroup 'Secrets - After' {
                    $after = Get-GitHubSecret @scope -Name "*$os*"
                    Write-Host "$($after | Format-Table | Out-String)"
                }
                $after.Count | Should -Be 0
            }
        }
    }
}
