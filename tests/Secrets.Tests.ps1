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
    $testName = 'SecretsTest'
    $os = $env:RUNNER_OS
    $guid = [guid]::NewGuid().ToString()
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
            $repoName = "$testName-$os-$TokenType-$guid"
            $secretPrefix = ("$testName`_$os`_$TokenType" -replace '-', '_').ToUpper()
            $secretName = ("$secretPrefix`_$guid" -replace '-', '_').ToUpper()
            $environmentName = "$testName-$os-$TokenType-$guid"

            switch ($OwnerType) {
                'user' {
                    $repo = New-GitHubRepository -Name $repoName -AllowSquashMerge
                    $repo2 = New-GitHubRepository -Name "$repoName-2" -AllowSquashMerge
                    $repo3 = New-GitHubRepository -Name "$repoName-3" -AllowSquashMerge
                }
                'organization' {
                    $repo = New-GitHubRepository -Owner $owner -Name $repoName -AllowSquashMerge
                    $repo2 = New-GitHubRepository -Owner $owner -Name "$repoName-2" -AllowSquashMerge
                    $repo3 = New-GitHubRepository -Owner $owner -Name "$repoName-3" -AllowSquashMerge
                    LogGroup "Org secret - [$secretName]" {
                        $params = @{
                            Owner                = $owner
                            Value                = 'organization'
                            Visibility           = 'selected'
                            SelectedRepositories = $repo.id
                        }
                        $result = @()
                        $result += Set-GitHubSecret @params -Name "$secretName`_1"
                        $result += Set-GitHubSecret @params -Name "$secretName`_2"
                        $result += Set-GitHubSecret @params -Name "$secretName`_3"
                        Write-Host ($result | Select-Object * | Format-Table | Out-String)
                    }
                }
            }
            LogGroup "Repository - [$repoName]" {
                Write-Host ($repo | Format-List | Out-String)
                Write-Host ($repo2 | Format-List | Out-String)
                Write-Host ($repo3 | Format-List | Out-String)
            }
        }

        AfterAll {
            Write-Host 'After all'
            switch ($OwnerType) {
                'user' {
                    Remove-GitHubRepository -Owner $owner -Name $repoName -Confirm:$false
                }
                'organization' {
                    $orgSecrets = Get-GitHubSecret -Owner $owner
                    LogGroup 'Secrets to remove' {
                        Write-Host "$($orgSecrets | Format-List | Out-String)"
                    }
                    $orgSecrets | Remove-GitHubSecret
                    Remove-GitHubRepository -Owner $owner -Name $repoName -Confirm:$false
                    Remove-GitHubRepository -Owner $owner -Name "$repoName-2" -Confirm:$false
                    Remove-GitHubRepository -Owner $owner -Name "$repoName-3" -Confirm:$false
                }
            }
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
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
                    $org = Get-GitHubOrganization -Organization $owner
                    Write-Host ($org | Format-List | Out-String)
                }
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
                $name = "$secretPrefix`TestSecret"
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
                $result.Visibility | Should -Be 'private'
            }

            It 'Set-GitHubSecret - should update an existing organization secret' {
                $name = "$secretPrefix`TestSecret"
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
                $result.Visibility | Should -Be 'all'
            }

            It 'Get-GitHubSecret' {
                $result = Get-GitHubSecret @scope -Name "$secretPrefix*"
                LogGroup 'Secrets' {
                    Write-Host "$($result | Select-Object * | Format-List | Out-String)"
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Remove-GitHubSecret' {
                $testSecretName = "$secretPrefix`TestSecret*"
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
                    LogGroup "SelectedRepositories - [$secretName]" {
                        $result = Get-GitHubSecretSelectedRepository -Owner $owner -Name $secretName
                        Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                    $result[0] | Should -BeOfType [GitHubRepository]
                    $result | Should -HaveCount 1
                }
                It 'Add-GitHubSecretSelectedRepository - adds a repository to the list of selected repositories' {
                    { Add-GitHubSecretSelectedRepository -Owner $owner -Name $secretName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Add-GitHubSecretSelectedRepository - adds a repository to the list of selected repositories - idempotency test' {
                    { Add-GitHubSecretSelectedRepository -Owner $owner -Name $secretName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Add-GitHubSecretSelectedRepository - adds a repository to the list of selected repositories using pipeline' {
                    LogGroup 'Repo3' {
                        Write-Host "$($repo3 | Format-List | Out-String)"
                    }
                    { $repo3 | Add-GitHubSecretSelectedRepository -Owner $owner -Name $secretName } | Should -Not -Throw
                }
                It 'Get-GitHubSecretSelectedRepository - gets 3 repositories' {
                    LogGroup "SelectedRepositories - [$secretName]" {
                        $result = Get-GitHubSecretSelectedRepository -Owner $owner -Name $secretName
                        Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                    $result[0] | Should -BeOfType [GitHubRepository]
                    $result | Should -HaveCount 3
                }
                It 'Remove-GitHubSecretSelectedRepository - removes a repository from the list of selected repositories' {
                    { Remove-GitHubSecretSelectedRepository -Owner $owner -Name $secretName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Remove-GitHubSecretSelectedRepository - removes a repository from the list of selected repositories - idempotency test' {
                    { Remove-GitHubSecretSelectedRepository -Owner $owner -Name $secretName -RepositoryID $repo2.id } | Should -Not -Throw
                }
                It 'Remove-GitHubSecretSelectedRepository - removes a repository from the list of selected repositories using pipeline' {
                    LogGroup 'Repo3' {
                        Write-Host "$($repo3 | Format-List | Out-String)"
                    }
                    { $repo3 | Remove-GitHubSecretSelectedRepository -Owner $owner -Name $secretName } | Should -Not -Throw
                }
                It 'Get-GitHubSecretSelectedRepository - gets 1 repository' {
                    LogGroup "SelectedRepositories - [$secretName]" {
                        $result = Get-GitHubSecretSelectedRepository -Owner $owner -Name $secretName
                        Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
                    }
                    $result | Should -Not -BeNullOrEmpty
                    $result[0] | Should -BeOfType [GitHubRepository]
                    $result | Should -HaveCount 1
                }
                It 'Set-GitHubSecretSelectedRepository - should set the selected repositories for the secret' {
                    { Set-GitHubSecretSelectedRepository -Owner $owner -Name $secretName -RepositoryID $repo.id, $repo2.id, $repo3.id } |
                        Should -Not -Throw
                }
                It 'Set-GitHubSecretSelectedRepository - should set the selected repositories for the secret - idempotency test' {
                    { Set-GitHubSecretSelectedRepository -Owner $owner -Name $secretName -RepositoryID $repo.id, $repo2.id, $repo3.id } |
                        Should -Not -Throw
                }
                It 'Get-GitHubSecretSelectedRepository - gets 3 repository' {
                    $result = Get-GitHubSecretSelectedRepository -Owner $owner -Name $secretName
                    LogGroup "SelectedRepositories - [$secretName]" {
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
                    Repository = $repoName
                }
                Set-GitHubSecret @scope -Name $secretName -Value 'repository'
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

            # It 'Set-GitHubSecret' {
            #     $param = @{
            #         Name  = "$secretPrefix`TestSecret"
            #         Value = 'TestValue'
            #     }
            #     $result = Set-GitHubSecret @param @scope
            #     $result = Set-GitHubSecret @param @scope
            #     $result | Should -Not -BeNullOrEmpty
            # }

            # It 'Update-GitHubSecret' {
            #     $param = @{
            #         Name  = "$secretPrefix`TestSecret"
            #         Value = 'TestValue1234'
            #     }
            #     $result = Update-GitHubSecret @param @scope -PassThru
            #     $result | Should -Not -BeNullOrEmpty
            # }

            # It 'New-GitHubSecret' {
            #     $param = @{
            #         Name  = "$secretPrefix`TestSecret2"
            #         Value = 'TestValue123'
            #     }
            #     $result = New-GitHubSecret @param @scope
            #     $result | Should -Not -BeNullOrEmpty
            # }

            # It 'Get-GitHubSecret' {
            #     $result = Get-GitHubSecret @scope -Name "*$os*"
            #     LogGroup 'Secrets' {
            #         Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
            #     }
            #     $result | Should -Not -BeNullOrEmpty
            # }

            # It 'Get-GitHubSecret -IncludeInherited' {
            #     $result = Get-GitHubSecret @scope -Name "*$os*" -IncludeInherited
            #     LogGroup 'Secrets' {
            #         Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
            #     }
            #     $result | Should -Not -BeNullOrEmpty
            # }

            # It 'Remove-GitHubSecret' {
            #     $before = Get-GitHubSecret @scope -Name "*$os*"
            #     LogGroup 'Secrets - Before' {
            #         Write-Host "$($before | Format-Table | Out-String)"
            #     }
            #     $before | Remove-GitHubSecret
            #     $after = Get-GitHubSecret @scope -Name "*$os*"
            #     LogGroup 'Secrets -After' {
            #         Write-Host "$($after | Format-Table | Out-String)"
            #     }
            #     $after.Count | Should -Be 0
            # }
        }

        Context 'Environment' -Skip:($OwnerType -eq 'repository') {
            BeforeAll {
                $scope = @{
                    Owner      = $owner
                    Repository = $repoName
                }
                Set-GitHubSecret @scope -Name $secretName -Value 'repository'
                $scope = @{
                    Owner       = $owner
                    Repository  = $repoName
                    Environment = $environmentName
                }
                Set-GitHubEnvironment -Owner $owner -Repository $repoName -Name $environmentName
                Set-GitHubSecret @scope -Name $secretName -Value 'environment'
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

            # It 'Set-GitHubSecret' {
            #     $param = @{
            #         Name  = "$secretPrefix`TestSecret"
            #         Value = 'TestValue'
            #     }
            #     $result = Set-GitHubSecret @param @scope
            #     $result = Set-GitHubSecret @param @scope
            #     LogGroup 'Secrets' {
            #         Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
            #     }
            #     $result | Should -Not -BeNullOrEmpty
            # }

            # It 'Update-GitHubSecret' {
            #     $param = @{
            #         Name  = "$secretPrefix`TestSecret"
            #         Value = 'TestValue1234'
            #     }
            #     $result = Update-GitHubSecret @param @scope -PassThru
            #     LogGroup 'Secrets' {
            #         Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
            #     }
            #     $result | Should -Not -BeNullOrEmpty
            # }

            # It 'New-GitHubSecret' {
            #     $param = @{
            #         Name  = "$secretPrefix`TestSecret2"
            #         Value = 'TestValue123'
            #     }
            #     $result = New-GitHubSecret @param @scope
            #     LogGroup 'Secrets' {
            #         Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
            #     }
            #     $result | Should -Not -BeNullOrEmpty
            # }

            # It 'Get-GitHubSecret' {
            #     $result = Get-GitHubSecret @scope -Name "*$os*"
            #     LogGroup 'Secrets' {
            #         Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
            #     }
            #     $result | Should -Not -BeNullOrEmpty
            # }

            # It 'Get-GitHubSecret -IncludeInherited' {
            #     $result = Get-GitHubSecret @scope -Name "*$os*" -IncludeInherited
            #     LogGroup 'Secrets' {
            #         Write-Host "$($result | Select-Object * | Format-Table | Out-String)"
            #     }
            #     $result | Should -Not -BeNullOrEmpty
            # }

            # It 'Remove-GitHubSecret' {
            #     LogGroup 'Secrets - Before' {
            #         $before = Get-GitHubSecret @scope -Name "*$os*"
            #         Write-Host "$($before | Format-Table | Out-String)"
            #     }
            #     $before | Remove-GitHubSecret
            #     LogGroup 'Secrets - After' {
            #         $after = Get-GitHubSecret @scope -Name "*$os*"
            #         Write-Host "$($after | Format-Table | Out-String)"
            #     }
            #     $after.Count | Should -Be 0
            # }
        }
    }
}
