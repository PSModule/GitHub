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
    $repo = 'EnvironmentTest'
    $environmentName = 'production'
}

Describe 'As a user - Fine-grained PAT token - user account access (USER_FG_PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_USER_FG_PAT
        $owner = 'psmodule-user'
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Environments' {
        It 'Get-GitHubEnvironment - lists all environments' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result | Should -BeNullOrEmpty
        }

        It 'Get-GitHubEnvironment - retrieves a specific environment that does not exist yet' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -BeNullOrEmpty
        }

        It 'Set-GitHubEnvironment - creates an environment' {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -WaitTimer 10
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
            $result.Protection.WaitTimer | Should -Be 10
        }

        It 'Get-GitHubEnvironment - retrieves a specific environment' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
        }

        It 'Get-GitHubEnvironment - lists all environments' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result | Should -BeOfType [System.Array]
        }

        It 'Remove-GitHubEnvironment - deletes an environment' {
            $result = Remove-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'As a user - Fine-grained PAT token - organization account access (ORG_FG_PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_ORG_FG_PAT
        $owner = 'psmodule-test-org2'
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Environments' {
        It 'Get-GitHubEnvironment - lists all environments' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result | Should -BeNullOrEmpty
        }

        It 'Get-GitHubEnvironment - retrieves a specific environment that does not exist yet' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -BeNullOrEmpty
        }

        It 'Set-GitHubEnvironment - creates an environment' {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -WaitTimer 10
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
            $result.Protection.WaitTimer | Should -Be 10
        }

        It 'Get-GitHubEnvironment - retrieves a specific environment' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
        }

        It 'Get-GitHubEnvironment - lists all environments' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result | Should -BeOfType [System.Array]
        }

        It 'Remove-GitHubEnvironment - deletes an environment' {
            $result = Remove-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'As a user - Classic PAT token (PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_PAT
        $owner = 'psmodule-user'
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Environments' {
        It 'Get-GitHubEnvironment - lists all environments' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result | Should -BeNullOrEmpty
        }

        It 'Get-GitHubEnvironment - retrieves a specific environment that does not exist yet' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -BeNullOrEmpty
        }

        It 'Set-GitHubEnvironment - creates an environment' {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -WaitTimer 10
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
            $result.Protection.WaitTimer | Should -Be 10
        }

        It 'Get-GitHubEnvironment - retrieves a specific environment' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
        }

        It 'Get-GitHubEnvironment - lists all environments' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result | Should -BeOfType [System.Array]
        }

        It 'Remove-GitHubEnvironment - deletes an environment' {
            $result = Remove-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'As GitHub Actions (GHA)' {
    BeforeAll {
        Connect-GitHubAccount
        $owner = 'PSModule'
        $repo = 'GitHub'
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Environments' {
        # TESTS HERE
    }
}

Describe 'As a GitHub App - Enterprise (APP_ENT)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ENT_CLIENT_ID -PrivateKey $env:TEST_APP_ENT_PRIVATE_KEY
        $owner = 'psmodule-test-org3'
        # repo: EnvironmentTest
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Environments' {
        It 'Get-GitHubEnvironment - lists all environments' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result | Should -BeNullOrEmpty
        }

        It 'Get-GitHubEnvironment - retrieves a specific environment that does not exist yet' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -BeNullOrEmpty
        }

        It 'Set-GitHubEnvironment - creates an environment' {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -WaitTimer 10
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
            $result.Protection.WaitTimer | Should -Be 10
        }

        It 'Get-GitHubEnvironment - retrieves a specific environment' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
        }

        It 'Get-GitHubEnvironment - lists all environments' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result | Should -BeOfType [System.Array]
        }

        It 'Remove-GitHubEnvironment - deletes an environment' {
            $result = Remove-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'As a GitHub App - Organization (APP_ORG)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
        $owner = 'psmodule-test-org'
        # repo: EnvironmentTest
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Environments' {
        It 'Get-GitHubEnvironment - lists all environments' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result | Should -BeNullOrEmpty
        }

        It 'Get-GitHubEnvironment - retrieves a specific environment that does not exist yet' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -BeNullOrEmpty
        }

        It 'Set-GitHubEnvironment - creates an environment' {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -WaitTimer 10
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
            $result.Protection.WaitTimer | Should -Be 10
        }

        It 'Get-GitHubEnvironment - retrieves a specific environment' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
        }

        It 'Get-GitHubEnvironment - lists all environments' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result | Should -BeOfType [System.Array]
        }

        It 'Remove-GitHubEnvironment - deletes an environment' {
            $result = Remove-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }
    }
}
