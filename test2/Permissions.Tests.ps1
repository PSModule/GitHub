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

Describe 'Permissions' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
        }

        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            Write-Host ('-' * 60)
        }

        Context 'For Apps' -Skip:($AuthType -ne 'APP') {
            BeforeAll {
                $permissionsDefinitions = [GitHubPermissionDefinition]::List
                $installationContext = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                LogGroup 'Context - Installation' {
                    Write-Host "$($installationContext | Format-List | Out-String)"
                }
                LogGroup 'Permissions' {
                    Write-Host "$($installationContext.Permissions | Format-Table | Out-String)"
                }
            }

            It 'App context should have Permissions property populated' {
                $installationContext.Permissions.Count | Should -BeGreaterThan 0
                $installationContext.Permissions | Should -BeOfType [GitHubPermission]
                $installationContext.Permissions.Name | Should -BeIn $permissionsDefinitions.Name
            }

            It 'Permission catalog should contain all permissions granted to the app installation' {
                $missing = @()
                $installationContext.Permissions | ForEach-Object {
                    if ($_.Name -notin $permissionsDefinitions.Name) {
                        $missing += $_.Name
                    }
                }
                $missing.Count | Should -Be 0 -Because "The following permissions are missing from the catalog: $($missing -join ', ')"
            }
        }
    }

    Context 'Get-GitHubPermissionDefinition' {
        It 'Should return all permission definitions when called without parameters' {
            $result = Get-GitHubPermissionDefinition
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [GitHubPermissionDefinition]
            $result.Count | Should -BeGreaterThan 0
        }

        It 'Should return only Fine-grained permissions when filtered by Type' {
            $result = Get-GitHubPermissionDefinition -Type Fine-grained
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [GitHubPermissionDefinition]
            $result | ForEach-Object { $_.Type | Should -Be 'Fine-grained' }
        }

        It 'Should return only Repository permissions when filtered by Scope' {
            $result = Get-GitHubPermissionDefinition -Scope Repository
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [GitHubPermissionDefinition]
            $result | ForEach-Object { $_.Scope | Should -Be 'Repository' }
        }

        It 'Should return only Organization permissions when filtered by Scope' {
            $result = Get-GitHubPermissionDefinition -Scope Organization
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [GitHubPermissionDefinition]
            $result | ForEach-Object { $_.Scope | Should -Be 'Organization' }
        }

        It 'Should return only User permissions when filtered by Scope' {
            $result = Get-GitHubPermissionDefinition -Scope User
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [GitHubPermissionDefinition]
            $result | ForEach-Object { $_.Scope | Should -Be 'User' }
        }

        It 'Should filter by both Type and Scope when both are specified' {
            $result = Get-GitHubPermissionDefinition -Type Fine-grained -Scope Repository
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [GitHubPermissionDefinition]
            $result | ForEach-Object {
                $_.Type | Should -Be 'Fine-grained'
                $_.Scope | Should -Be 'Repository'
            }
        }

        It 'Should include expected properties for each permission' {
            $result = Get-GitHubPermissionDefinition | Select-Object -First 1
            $result.Name | Should -Not -BeNullOrEmpty
            $result.DisplayName | Should -Not -BeNullOrEmpty
            $result.Description | Should -Not -BeNullOrEmpty
            $result.URL | Should -Not -BeNullOrEmpty
            $result.Options | Should -Not -BeNullOrEmpty
            $result.Type | Should -Not -BeNullOrEmpty
            $result.Scope | Should -Not -BeNullOrEmpty
        }

        It 'Should include the contents permission for repositories' {
            $result = Get-GitHubPermissionDefinition | Where-Object { $_.Name -eq 'contents' }
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be 'contents'
            $result.DisplayName | Should -Be 'Contents'
            $result.Scope | Should -Be 'Repository'
            $result.Type | Should -Be 'Fine-grained'
            $result.Options | Should -Contain 'read'
            $result.Options | Should -Contain 'write'
        }

        It 'Should include the members permission for organizations' {
            $result = Get-GitHubPermissionDefinition | Where-Object { $_.Name -eq 'members' }
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be 'members'
            $result.DisplayName | Should -Be 'Members'
            $result.Scope | Should -Be 'Organization'
            $result.Type | Should -Be 'Fine-grained'
            $result.Options | Should -Contain 'read'
            $result.Options | Should -Contain 'write'
        }

        It 'Should include profile permission for users' {
            $result = Get-GitHubPermissionDefinition | Where-Object { $_.Name -eq 'profile' }
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be 'profile'
            $result.DisplayName | Should -Be 'Profile'
            $result.Scope | Should -Be 'User'
            $result.Type | Should -Be 'Fine-grained'
            $result.Options | Should -Contain 'write'
        }
    }

    Context 'GitHubPermission Class' {
        BeforeAll {
            $permission = [GitHubPermissionDefinition]@{
                Name        = 'test'
                DisplayName = 'Test Permission'
                Description = 'A test permission'
                URL         = 'https://docs.github.com/test'
                Options     = @('read', 'write')
                Type        = 'Fine-grained'
                Scope       = 'Repository'
            }
        }

        It 'Should create a GitHubPermission object with all properties' {
            $permission | Should -Not -BeNullOrEmpty
            $permission.Name | Should -Be 'test'
            $permission.DisplayName | Should -Be 'Test Permission'
            $permission.Description | Should -Be 'A test permission'
            $permission.URL | Should -Be 'https://docs.github.com/test'
            $permission.Options | Should -Contain 'read'
            $permission.Options | Should -Contain 'write'
            $permission.Type | Should -Be 'Fine-grained'
            $permission.Scope | Should -Be 'Repository'
        }

        It 'Should have a meaningful ToString() method' {
            $result = $permission.ToString()
            $result | Should -Be 'test'
        }
    }
}
