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
    $os = Get-GitHubRunnerData | Select-Object -ExpandProperty OS
}

Describe 'As a user - Fine-grained PAT token - user account access (USER_FG_PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_USER_FG_PAT
        $owner = 'psmodule-user'
        $testType = 'USER_FG_PAT'
        $repoName = "$testName-$os-$testType"
        $varName = "$testName`_$os`_$testType"
        $variablePrefix = "$varName`_"
        $environmentName = "$testName-$os-$testType"
        $repo = New-GitHubRepository -Name $repoName -AllowSquashMerge
    }
    AfterAll {
        Remove-GitHubRepository -Owner $owner -Name $repoName -Confirm:$false
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Repository' {
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
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable -All' {
            $result = Get-GitHubVariable @scope -Name "*$os*" -All
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            $before = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($before | Out-String)"
            $before | Remove-GitHubVariable
            $after = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($after | Out-String)"
            $after.Count | Should -Be 0
        }
    }
    Context 'Environment' {
        BeforeAll {
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
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable -All' {
            $result = Get-GitHubVariable @scope -Name "*$os*" -All
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            $before = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($before | Out-String)"
            $before | Remove-GitHubVariable
            $after = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($after | Out-String)"
            $after.Count | Should -Be 0
        }
    }
}

Describe 'As a user - Fine-grained PAT token - organization account access (ORG_FG_PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_ORG_FG_PAT
        $owner = 'psmodule-test-org2'
        $testType = 'ORG_FG_PAT'
        $repoName = "$testName-$os-$testType"
        $varName = "$testName`_$os`_$testType"
        $variablePrefix = "$varName`_"
        $environmentName = "$testName-$os-$testType"
        $repo = New-GitHubRepository -Owner $owner -Name $repoName -AllowSquashMerge
    }
    AfterAll {
        Remove-GitHubRepository -Owner $owner -Name $repoName -Confirm:$false
        Get-GitHubVariable -Owner $owner -Name "*$os*" | Remove-GitHubVariable
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Organization' {
        BeforeAll {
            $scope = @{
                Owner = $owner
            }
            Set-GitHubVariable @scope -Name $varName -Value 'organization' -Visibility selected -SelectedRepositories $repo.id
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
                Name       = "$variablePrefix`TestVariable"
                Value      = 'TestValue1234'
                Visibility = 'all'
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
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable -All' {
            $result = Get-GitHubVariable @scope -Name "*$os*" -All
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            $before = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($before | Out-String)"
            $before | Remove-GitHubVariable
            $after = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($after | Out-String)"
            $after.Count | Should -Be 0
        }
    }
    Context 'Repository' {
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
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable -All' {
            $result = Get-GitHubVariable @scope -Name "*$os*" -All
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            $before = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($before | Out-String)"
            $before | Remove-GitHubVariable
            $after = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($after | Out-String)"
            $after.Count | Should -Be 0
        }
    }
    Context 'Environment' {
        BeforeAll {
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
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable -All' {
            $result = Get-GitHubVariable @scope -Name "*$os*" -All
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            $before = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($before | Out-String)"
            $before | Remove-GitHubVariable
            $after = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($after | Out-String)"
            $after.Count | Should -Be 0
        }
    }
}

Describe 'As a user - Classic PAT token (PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_PAT
        $owner = 'psmodule-test-org2'
        $testType = 'PAT'
        $repoName = "$testName-$os-$testType"
        $varName = "$testName`_$os`_$testType"
        $variablePrefix = "$varName`_"
        $environmentName = "$testName-$os-$testType"
        $repo = New-GitHubRepository -Owner $owner -Name $repoName -AllowSquashMerge
    }
    AfterAll {
        Remove-GitHubRepository -Owner $owner -Name $repoName -Confirm:$false
        Get-GitHubVariable -Owner $owner -Name "*$os*" | Remove-GitHubVariable
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Organization' {
        BeforeAll {
            $scope = @{
                Owner = $owner
            }
            Set-GitHubVariable @scope -Name $varName -Value 'organization' -Visibility selected -SelectedRepositories $repo.id
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
                Name       = "$variablePrefix`TestVariable"
                Value      = 'TestValue1234'
                Visibility = 'all'
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
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable -All' {
            $result = Get-GitHubVariable @scope -Name "*$os*" -All
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            $before = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($before | Out-String)"
            $before | Remove-GitHubVariable
            $after = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($after | Out-String)"
            $after.Count | Should -Be 0
        }
    }
    Context 'Repository' {
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
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable -All' {
            $result = Get-GitHubVariable @scope -Name "*$os*" -All
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            $before = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($before | Out-String)"
            $before | Remove-GitHubVariable
            $after = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($after | Out-String)"
            $after.Count | Should -Be 0
        }
    }
    Context 'Environment' {
        BeforeAll {
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
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable -All' {
            $result = Get-GitHubVariable @scope -Name "*$os*" -All
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            $before = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($before | Out-String)"
            $before | Remove-GitHubVariable
            $after = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($after | Out-String)"
            $after.Count | Should -Be 0
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
        $testType = 'APP_ENT'
        $repoName = "$testName-$os-$testType"
        $varName = "$testName`_$os`_$testType"
        $variablePrefix = "$varName`_"
        $environmentName = "$testName-$os-$testType"
        $repo = New-GitHubRepository -Owner $owner -Name $repoName -AllowSquashMerge
    }
    AfterAll {
        Remove-GitHubRepository -Owner $owner -Name $repoName -Confirm:$false
        Get-GitHubVariable -Owner $owner -Name "*$os*" | Remove-GitHubVariable
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Organization' {
        BeforeAll {
            $scope = @{
                Owner = $owner
            }
            Set-GitHubVariable @scope -Name $varName -Value 'organization' -Visibility selected -SelectedRepositories $repo.id
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
                Name       = "$variablePrefix`TestVariable"
                Value      = 'TestValue1234'
                Visibility = 'all'
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
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable -All' {
            $result = Get-GitHubVariable @scope -Name "*$os*" -All
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            $before = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($before | Out-String)"
            $before | Remove-GitHubVariable
            $after = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($after | Out-String)"
            $after.Count | Should -Be 0
        }
    }
    Context 'Repository' {
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
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable -All' {
            $result = Get-GitHubVariable @scope -Name "*$os*" -All
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            $before = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($before | Out-String)"
            $before | Remove-GitHubVariable
            $after = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($after | Out-String)"
            $after.Count | Should -Be 0
        }
    }
    Context 'Environment' {
        BeforeAll {
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
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable -All' {
            $result = Get-GitHubVariable @scope -Name "*$os*" -All
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            $before = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($before | Out-String)"
            $before | Remove-GitHubVariable
            $after = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($after | Out-String)"
            $after.Count | Should -Be 0
        }
    }
}

Describe 'As a GitHub App - Organization (APP_ORG)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
        $owner = 'psmodule-test-org'
        Connect-GitHubApp -Organization $owner -Default
        $testType = 'APP_ORG'
        $repoName = "$testName-$os-$testType"
        $varName = "$testName`_$os`_$testType"
        $variablePrefix = "$varName`_"
        $environmentName = "$testName-$os-$testType"
        $repo = New-GitHubRepository -Owner $owner -Name $repoName -AllowSquashMerge
    }
    AfterAll {
        Remove-GitHubRepository -Owner $owner -Name $repoName -Confirm:$false
        Get-GitHubVariable -Owner $owner -Name "*$os*" | Remove-GitHubVariable
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Organization' {
        BeforeAll {
            $scope = @{
                Owner = $owner
            }
            Set-GitHubVariable @scope -Name $varName -Value 'organization' -Visibility selected -SelectedRepositories $repo.id
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
                Name       = "$variablePrefix`TestVariable"
                Value      = 'TestValue1234'
                Visibility = 'all'
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
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable -All' {
            $result = Get-GitHubVariable @scope -Name "*$os*" -All
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            $before = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($before | Out-String)"
            $before | Remove-GitHubVariable
            $after = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($after | Out-String)"
            $after.Count | Should -Be 0
        }
    }
    Context 'Repository' {
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
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable -All' {
            $result = Get-GitHubVariable @scope -Name "*$os*" -All
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            $before = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($before | Out-String)"
            $before | Remove-GitHubVariable
            $after = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($after | Out-String)"
            $after.Count | Should -Be 0
        }
    }
    Context 'Environment' {
        BeforeAll {
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
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubVariable -All' {
            $result = Get-GitHubVariable @scope -Name "*$os*" -All
            Write-Host "$($result | Out-String)"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Remove-GitHubVariable' {
            $before = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($before | Out-String)"
            $before | Remove-GitHubVariable
            $after = Get-GitHubVariable @scope -Name "*$os*"
            Write-Host "$($after | Out-String)"
            $after.Count | Should -Be 0
        }
    }
}
