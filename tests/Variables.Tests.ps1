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
    $os = Get-GitHubRunnerData | Select-Object -ExpandProperty OS
    $prefix = $os + 'ORG_FG_PAT'
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
    Context 'Repository' {
        BeforeAll {
            $scope = @{
                Owner      = $owner
                Repository = $repo
            }
        }
        It 'Set-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param @scope
            $result = Set-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue1234'
            }
            $result = Update-GitHubVariable @param @scope -PassThru
            $result | Should -Not -BeNullOrEmpty
        }

        It 'New-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable2"
                Value = 'TestValue123'
            }
            $result = New-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable' {
            $result = Get-GitHubVariable @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            Get-GitHubVariable @scope | Remove-GitHubVariable
            (Get-GitHubVariable @scope).Count | Should -Be 0
        }
    }
    Context 'Environment' {
        BeforeAll {
            $scope = @{
                Owner       = $owner
                Repository  = $repo
                Environment = $environmentName
            }
        }
        It 'Set-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param @scope
            $result = Set-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue1234'
            }
            $result = Update-GitHubVariable @param @scope -PassThru
            $result | Should -Not -BeNullOrEmpty
        }

        It 'New-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable2"
                Value = 'TestValue123'
            }
            $result = New-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable' {
            $result = Get-GitHubVariable @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            Get-GitHubVariable @scope | Remove-GitHubVariable
            (Get-GitHubVariable @scope).Count | Should -Be 0
        }
    }
}

Describe 'As a user - Fine-grained PAT token - organization account access (ORG_FG_PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_ORG_FG_PAT
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
    Context 'Organization' {
        BeforeAll {
            $scope = @{
                Owner = $owner
            }
        }
        It 'Set-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param @scope
            $result = Set-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubVariable' {
            $param = @{
                Name       = "$prefix`TestVariable"
                Value      = 'TestValue1234'
                Visibility = 'all'
            }
            $result = Update-GitHubVariable @param @scope -PassThru
            $result | Should -Not -BeNullOrEmpty
        }

        It 'New-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable2"
                Value = 'TestValue123'
            }
            $result = New-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable' {
            $result = Get-GitHubVariable @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            Get-GitHubVariable @scope | Remove-GitHubVariable
            (Get-GitHubVariable @scope).Count | Should -Be 0
        }
    }
    Context 'Repository' {
        BeforeAll {
            $scope = @{
                Owner      = $owner
                Repository = $repo
            }
        }
        It 'Set-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param @scope
            $result = Set-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue1234'
            }
            $result = Update-GitHubVariable @param @scope -PassThru
            $result | Should -Not -BeNullOrEmpty
        }

        It 'New-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable2"
                Value = 'TestValue123'
            }
            $result = New-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable' {
            $result = Get-GitHubVariable @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            Get-GitHubVariable @scope | Remove-GitHubVariable
            (Get-GitHubVariable @scope).Count | Should -Be 0
        }
    }
    Context 'Environment' {
        BeforeAll {
            $scope = @{
                Owner       = $owner
                Repository  = $repo
                Environment = $environmentName
            }
        }
        It 'Set-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param @scope
            $result = Set-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue1234'
            }
            $result = Update-GitHubVariable @param @scope -PassThru
            $result | Should -Not -BeNullOrEmpty
        }

        It 'New-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable2"
                Value = 'TestValue123'
            }
            $result = New-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable' {
            $result = Get-GitHubVariable @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            Get-GitHubVariable @scope | Remove-GitHubVariable
            (Get-GitHubVariable @scope).Count | Should -Be 0
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
    Context 'Organization' {
        BeforeAll {
            $scope = @{
                Owner = $owner
            }
        }
        It 'Set-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param @scope
            $result = Set-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubVariable' {
            $param = @{
                Name       = "$prefix`TestVariable"
                Value      = 'TestValue1234'
                Visibility = 'all'
            }
            $result = Update-GitHubVariable @param @scope -PassThru
            $result | Should -Not -BeNullOrEmpty
        }

        It 'New-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable2"
                Value = 'TestValue123'
            }
            $result = New-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable' {
            $result = Get-GitHubVariable @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            Get-GitHubVariable @scope | Remove-GitHubVariable
            (Get-GitHubVariable @scope).Count | Should -Be 0
        }
    }
    Context 'Repository' {
        BeforeAll {
            $scope = @{
                Owner      = $owner
                Repository = $repo
            }
        }
        It 'Set-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param @scope
            $result = Set-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue1234'
            }
            $result = Update-GitHubVariable @param @scope -PassThru
            $result | Should -Not -BeNullOrEmpty
        }

        It 'New-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable2"
                Value = 'TestValue123'
            }
            $result = New-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable' {
            $result = Get-GitHubVariable @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            Get-GitHubVariable @scope | Remove-GitHubVariable
            (Get-GitHubVariable @scope).Count | Should -Be 0
        }
    }
    Context 'Environment' {
        BeforeAll {
            $scope = @{
                Owner       = $owner
                Repository  = $repo
                Environment = $environmentName
            }
        }
        It 'Set-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param @scope
            $result = Set-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue1234'
            }
            $result = Update-GitHubVariable @param @scope -PassThru
            $result | Should -Not -BeNullOrEmpty
        }

        It 'New-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable2"
                Value = 'TestValue123'
            }
            $result = New-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable' {
            $result = Get-GitHubVariable @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            Get-GitHubVariable @scope | Remove-GitHubVariable
            (Get-GitHubVariable @scope).Count | Should -Be 0
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
        Connect-GitHubApp -Organization $owner -Default
        $guid = [guid]::NewGuid().ToString()
        $repo = "$repoSuffix-$guid"
        New-GitHubRepository -Owner $owner -Name $repo -AllowSquashMerge
        Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
    }
    AfterAll {
        Remove-GitHubRepository -Owner $owner -Name $repo -Confirm:$false
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Organization' {
        BeforeAll {
            $scope = @{
                Owner = $owner
            }
        }
        It 'Set-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param @scope
            $result = Set-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubVariable' {
            $param = @{
                Name       = "$prefix`TestVariable"
                Value      = 'TestValue1234'
                Visibility = 'all'
            }
            $result = Update-GitHubVariable @param @scope -PassThru
            $result | Should -Not -BeNullOrEmpty
        }

        It 'New-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable2"
                Value = 'TestValue123'
            }
            $result = New-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable' {
            $result = Get-GitHubVariable @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            Get-GitHubVariable @scope | Remove-GitHubVariable
            (Get-GitHubVariable @scope).Count | Should -Be 0
        }
    }
    Context 'Repository' {
        BeforeAll {
            $scope = @{
                Owner      = $owner
                Repository = $repo
            }
        }
        It 'Set-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param @scope
            $result = Set-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue1234'
            }
            $result = Update-GitHubVariable @param @scope -PassThru
            $result | Should -Not -BeNullOrEmpty
        }

        It 'New-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable2"
                Value = 'TestValue123'
            }
            $result = New-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable' {
            $result = Get-GitHubVariable @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            Get-GitHubVariable @scope | Remove-GitHubVariable
            (Get-GitHubVariable @scope).Count | Should -Be 0
        }
    }
    Context 'Environment' {
        BeforeAll {
            $scope = @{
                Owner       = $owner
                Repository  = $repo
                Environment = $environmentName
            }
        }
        It 'Set-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param @scope
            $result = Set-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue1234'
            }
            $result = Update-GitHubVariable @param @scope -PassThru
            $result | Should -Not -BeNullOrEmpty
        }

        It 'New-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable2"
                Value = 'TestValue123'
            }
            $result = New-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable' {
            $result = Get-GitHubVariable @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            Get-GitHubVariable @scope | Remove-GitHubVariable
            (Get-GitHubVariable @scope).Count | Should -Be 0
        }
    }
}

Describe 'As a GitHub App - Organization (APP_ORG)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
        $owner = 'psmodule-test-org'
        Connect-GitHubApp -Organization $owner -Default
        $guid = [guid]::NewGuid().ToString()
        $repo = "$repoSuffix-$guid"
        New-GitHubRepository -Owner $owner -Name $repo -AllowSquashMerge
        Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
    }
    AfterAll {
        Remove-GitHubRepository -Owner $owner -Name $repo -Confirm:$false
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Organization' {
        BeforeAll {
            $scope = @{
                Owner = $owner
            }
        }
        It 'Set-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param @scope
            $result = Set-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubVariable' {
            $param = @{
                Name       = "$prefix`TestVariable"
                Value      = 'TestValue1234'
                Visibility = 'all'
            }
            $result = Update-GitHubVariable @param @scope -PassThru
            $result | Should -Not -BeNullOrEmpty
        }

        It 'New-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable2"
                Value = 'TestValue123'
            }
            $result = New-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable' {
            $result = Get-GitHubVariable @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            Get-GitHubVariable @scope | Remove-GitHubVariable
            (Get-GitHubVariable @scope).Count | Should -Be 0
        }
    }
    Context 'Repository' {
        BeforeAll {
            $scope = @{
                Owner      = $owner
                Repository = $repo
            }
        }
        It 'Set-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param @scope
            $result = Set-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue1234'
            }
            $result = Update-GitHubVariable @param @scope -PassThru
            $result | Should -Not -BeNullOrEmpty
        }

        It 'New-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable2"
                Value = 'TestValue123'
            }
            $result = New-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable' {
            $result = Get-GitHubVariable @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            Get-GitHubVariable @scope | Remove-GitHubVariable
            (Get-GitHubVariable @scope).Count | Should -Be 0
        }
    }
    Context 'Environment' {
        BeforeAll {
            $scope = @{
                Owner       = $owner
                Repository  = $repo
                Environment = $environmentName
            }
        }
        It 'Set-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue'
            }
            $result = Set-GitHubVariable @param @scope
            $result = Set-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable"
                Value = 'TestValue1234'
            }
            $result = Update-GitHubVariable @param @scope -PassThru
            $result | Should -Not -BeNullOrEmpty
        }

        It 'New-GitHubVariable' {
            $param = @{
                Name  = "$prefix`TestVariable2"
                Value = 'TestValue123'
            }
            $result = New-GitHubVariable @param @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable' {
            $result = Get-GitHubVariable @scope
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            Get-GitHubVariable @scope | Remove-GitHubVariable
            (Get-GitHubVariable @scope).Count | Should -Be 0
        }
    }
}
