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
                $permissionsDefinitions = [GitHubPermission]::NewPermissionList()
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

    Context 'GitHubPermission Class' {
        BeforeAll {
            $permission = [GitHubPermission]@{
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
