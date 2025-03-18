#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'Used to create a secure string for testing.'
)]
[CmdletBinding()]
param()

BeforeAll {
    $repoSuffix = 'VariableTest'
    $environmentName = 'production'
}

Describe 'As a user - Fine-grained PAT token - user account access (USER_FG_PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_USER_FG_PAT
        $owner = 'psmodule-user'
        $guid = [guid]::NewGuid().ToString()
        $repo = "$repoSuffix-$guid"
        New-GitHubRepository -Name $repo -AllowSquashMerge
        Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
    }
    AfterAll {
        Remove-GitHubRepository -Owner $owner -Name $repo -Confirm:$false
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Variables' {
        Context 'Repository' {
            It 'Set-GitHubVariable' {
                $param = @{
                    Name  = 'TestVariable'
                    Value = 'TestValue'
                }
                $result = Set-GitHubVariable @param -Owner $owner -Repository $repo
                $result = Set-GitHubVariable @param -Owner $owner -Repository $repo
                $result | Should -Not -BeNullOrEmpty

                $result | Remove-GitHubVariable
            }
        }

        Context 'Environment' {
            It 'Set-GitHubVariable' {
                $param = @{
                    Name  = 'TestVariable'
                    Value = 'TestValue'
                }
                $result = Set-GitHubVariable @param -Owner $owner -Repository $repo -Environment $environmentName
                $result = Set-GitHubVariable @param -Owner $owner -Repository $repo -Environment $environmentName
                $result | Should -Not -BeNullOrEmpty

                $result | Remove-GitHubVariable
            }
        }
    }
}

Describe 'As a user - Fine-grained PAT token - organization account access (ORG_FG_PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_ORG_FG_PAT
        $owner = 'psmodule-test-org2'
        $os = Get-GitHubRunnerData | Select-Object -ExpandProperty OS
        $prefix = $os + 'ORG_FG_PAT'
        $guid = [guid]::NewGuid().ToString()
        $repo = "$repoSuffix-$guid"
        New-GitHubRepository -Owner $owner -Name $repo -AllowSquashMerge
        Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
    }
    AfterAll {
        Remove-GitHubRepository -Owner $owner -Name $repo -Confirm:$false
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Variables' {
        Context 'Organization' {
            It 'Set-GitHubVariable' {
                $param = @{
                    Name  = "$prefix`TestVariable"
                    Value = 'TestValue'
                }
                $result = Set-GitHubVariable @param -Owner $owner
                $result = Set-GitHubVariable @param -Owner $owner
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Update-GitHubVariable' {
                $param = @{
                    Name       = "$prefix`TestVariable"
                    Value      = 'TestValue123'
                    Visibility = 'all'
                }
                $result = Update-GitHubVariable @param -Owner $owner
                $result | Should -Not -BeNullOrEmpty
            }

            It 'New-GitHubVariable' {
                $param = @{
                    Name  = "$prefix`TestVariable2"
                    Value = 'TestValue123'
                }
                $result = New-GitHubVariable @param -Owner $owner
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Get-GitHubVariable' {
                $result = Get-GitHubVariable -Owner $owner
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Remove-GitHubVariable' {
                Get-GitHubVariable -Owner $owner | Remove-GitHubVariable
                Get-GitHubVariable -Owner $owner | Should -BeNullOrEmpty
            }
        }

        Context 'Repository' {
            It 'Set-GitHubVariable' {
                $param = @{
                    Name  = "$prefix`TestVariable"
                    Value = 'TestValue'
                }
                $result = Set-GitHubVariable @param -Owner $owner -Repository $repo
                $result = Set-GitHubVariable @param -Owner $owner -Repository $repo
                $result | Should -Not -BeNullOrEmpty

                $result | Remove-GitHubVariable
            }
        }
        Context 'Environment' {
            It 'Set-GitHubVariable' {
                $param = @{
                    Name  = "$prefix`TestVariable"
                    Value = 'TestValue'
                }
                $result = Set-GitHubVariable @param -Owner $owner -Repository $repo -Environment $environmentName
                $result = Set-GitHubVariable @param -Owner $owner -Repository $repo -Environment $environmentName
                $result | Should -Not -BeNullOrEmpty

                $result | Remove-GitHubVariable
            }
        }


    }
}

Describe 'As a user - Classic PAT token (PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_PAT
        $owner = 'psmodule-test-org2'
        $guid = [guid]::NewGuid().ToString()
        $repo = "$repoSuffix-$guid"
        New-GitHubRepository -Owner $owner -Name $repo -AllowSquashMerge
        Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
    }
    AfterAll {
        Remove-GitHubRepository -Owner $owner -Name $repo -Confirm:$false
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Variables' {
        It 'Set-GitHubVariable - Repository' {
            $param = @{
                Name  = 'TestVariable'
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param -Owner $owner -Repository $repo
            $result = Set-GitHubVariable @param -Owner $owner -Repository $repo
            $result | Should -Not -BeNullOrEmpty

            $result | Remove-GitHubVariable
        }

        It 'Set-GitHubVariable - Environment' {
            $param = @{
                Name  = 'TestVariable'
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param -Owner $owner -Repository $repo -Environment $environmentName
            $result = Set-GitHubVariable @param -Owner $owner -Repository $repo -Environment $environmentName
            $result | Should -Not -BeNullOrEmpty

            $result | Remove-GitHubVariable
        }
    }
}

Describe 'As GitHub Actions (GHA)' {
    BeforeAll {
        Connect-GitHubAccount
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Variables' {

    }
}

Describe 'As a GitHub App - Enterprise (APP_ENT)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ENT_CLIENT_ID -PrivateKey $env:TEST_APP_ENT_PRIVATE_KEY
        $owner = 'psmodule-test-org3'
        $guid = [guid]::NewGuid().ToString()
        $repo = "$repoSuffix-$guid"
        Connect-GitHubApp -Organization $owner -Default
        New-GitHubRepository -Owner $owner -Name $repo -AllowSquashMerge
        Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
    }
    AfterAll {
        Remove-GitHubRepository -Owner $owner -Name $repo -Confirm:$false
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Variables' {
        It 'Set-GitHubVariable - Organization' {
            $param = @{
                Name  = 'TestVariable'
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param -Owner $owner
            $result = Set-GitHubVariable @param -Owner $owner
            $result | Should -Not -BeNullOrEmpty

            $result | Remove-GitHubVariable
        }

        It 'Set-GitHubVariable - Repository' {
            $param = @{
                Name  = 'TestVariable'
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param -Owner $owner -Repository $repo
            $result = Set-GitHubVariable @param -Owner $owner -Repository $repo
            $result | Should -Not -BeNullOrEmpty

            $result | Remove-GitHubVariable
        }

        It 'Set-GitHubVariable - Environment' {
            $param = @{
                Name  = 'TestVariable'
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param -Owner $owner -Repository $repo -Environment $environmentName
            $result = Set-GitHubVariable @param -Owner $owner -Repository $repo -Environment $environmentName
            $result | Should -Not -BeNullOrEmpty

            $result | Remove-GitHubVariable
        }
    }
}

Describe 'As a GitHub App - Organization (APP_ORG)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
        $owner = 'psmodule-test-org'
        $guid = [guid]::NewGuid().ToString()
        $repo = "$repoSuffix-$guid"
        Connect-GitHubApp -Organization $owner -Default
        New-GitHubRepository -Owner $owner -Name $repo -AllowSquashMerge
        Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
    }
    AfterAll {
        Remove-GitHubRepository -Owner $owner -Name $repo -Confirm:$false
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Variables' {
        It 'Set-GitHubVariable - Organization' {
            $param = @{
                Name  = 'TestVariable'
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param -Owner $owner
            $result = Set-GitHubVariable @param -Owner $owner
            $result | Should -Not -BeNullOrEmpty

            $result | Remove-GitHubVariable
        }

        It 'Set-GitHubVariable - Repository' {
            $param = @{
                Name  = 'TestVariable'
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param -Owner $owner -Repository $repo
            $result = Set-GitHubVariable @param -Owner $owner -Repository $repo
            $result | Should -Not -BeNullOrEmpty

            $result | Remove-GitHubVariable
        }

        It 'Set-GitHubVariable - Environment' {
            $param = @{
                Name  = 'TestVariable'
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param -Owner $owner -Repository $repo -Environment $environmentName
            $result = Set-GitHubVariable @param -Owner $owner -Repository $repo -Environment $environmentName
            $result | Should -Not -BeNullOrEmpty

            $result | Remove-GitHubVariable
        }
    }
}
