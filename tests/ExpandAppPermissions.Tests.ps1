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

Describe 'ExpandAppPermissions Configuration' {
    BeforeAll {
        # Import the module for testing
        Import-Module -Force "$PSScriptRoot/../src/loader.ps1"

        # Store original config state for cleanup
        $originalConfig = $null
        try {
            $originalConfig = Get-GitHubConfig
        } catch {
            # Config might not be initialized yet
        }
    }

    AfterAll {
        # Restore original config if it existed
        if ($originalConfig) {
            try {
                Reset-GitHubConfig
                foreach ($prop in $originalConfig.PSObject.Properties) {
                    if ($prop.Name -ne 'ID') {
                        Set-GitHubConfig -Name $prop.Name -Value $prop.Value
                    }
                }
            } catch {
                # Best effort restore
            }
        }
    }

    Context 'GitHubConfig Class' {
        It 'Should have ExpandAppPermissions property' {
            $config = [GitHubConfig]@{
                ID                   = 'Test'
                ExpandAppPermissions = $true
            }
            $config.ExpandAppPermissions | Should -Be $true

            $config.ExpandAppPermissions = $false
            $config.ExpandAppPermissions | Should -Be $false
        }

        It 'Should accept null value for ExpandAppPermissions' {
            $config = [GitHubConfig]@{
                ID                   = 'Test'
                ExpandAppPermissions = $null
            }
            $config.ExpandAppPermissions | Should -BeNullOrEmpty
        }
    }

    Context 'Default Configuration Values' {
        BeforeEach {
            # Reset to defaults before each test
            Reset-GitHubConfig
        }

        It 'Should have ExpandAppPermissions in default config' {
            $config = Get-GitHubConfig
            $config.PSObject.Properties.Name | Should -Contain 'ExpandAppPermissions'
        }

        It 'Should default to true for local environment' {
            # Mock the environment variables to simulate local environment
            $script:IsGitHubActions = $false
            $script:IsFunctionApp = $false
            $script:IsLocal = $true

            # Force re-initialization
            Reset-GitHubConfig

            $expandValue = Get-GitHubConfig -Name 'ExpandAppPermissions'
            $expandValue | Should -Be $true
        }

        It 'Should default to false for GitHub Actions environment' {
            # Mock the environment variables to simulate GitHub Actions
            $script:IsGitHubActions = $true
            $script:IsFunctionApp = $false
            $script:IsLocal = $false

            # Force re-initialization
            Reset-GitHubConfig

            $expandValue = Get-GitHubConfig -Name 'ExpandAppPermissions'
            $expandValue | Should -Be $false
        }

        It 'Should default to false for Azure Functions environment' {
            # Mock the environment variables to simulate Azure Functions
            $script:IsGitHubActions = $false
            $script:IsFunctionApp = $true
            $script:IsLocal = $false

            # Force re-initialization
            Reset-GitHubConfig

            $expandValue = Get-GitHubConfig -Name 'ExpandAppPermissions'
            $expandValue | Should -Be $false
        }
    }

    Context 'Configuration Management' {
        BeforeEach {
            Reset-GitHubConfig
        }

        It 'Should allow setting ExpandAppPermissions via Set-GitHubConfig' {
            Set-GitHubConfig -Name 'ExpandAppPermissions' -Value $false
            Get-GitHubConfig -Name 'ExpandAppPermissions' | Should -Be $false

            Set-GitHubConfig -Name 'ExpandAppPermissions' -Value $true
            Get-GitHubConfig -Name 'ExpandAppPermissions' | Should -Be $true
        }

        It 'Should allow removing ExpandAppPermissions via Remove-GitHubConfig' {
            Set-GitHubConfig -Name 'ExpandAppPermissions' -Value $false
            Remove-GitHubConfig -Name 'ExpandAppPermissions'
            $value = Get-GitHubConfig -Name 'ExpandAppPermissions'
            $value | Should -BeNullOrEmpty
        }

        It 'Should reset ExpandAppPermissions with Reset-GitHubConfig' {
            Set-GitHubConfig -Name 'ExpandAppPermissions' -Value $false
            Get-GitHubConfig -Name 'ExpandAppPermissions' | Should -Be $false

            Reset-GitHubConfig
            # Should return to environment default (true for local)
            Get-GitHubConfig -Name 'ExpandAppPermissions' | Should -Be $true
        }
    }

    Context 'GitHubAppInstallation Permission Handling' {
        BeforeAll {
            # Sample permission data for testing
            $samplePermissionData = [PSCustomObject]@{
                issues   = 'write'
                contents = 'read'
                actions  = 'write'
                metadata = 'read'
            }

            $sampleAppInstallationData = [PSCustomObject]@{
                id                   = 12345
                client_id            = 'Iv1.test'
                app_id               = 54321
                app_slug             = 'test-app'
                account              = [PSCustomObject]@{
                    login    = 'testuser'
                    type     = 'User'
                    html_url = 'https://github.com/testuser'
                }
                target_type          = 'User'
                repository_selection = 'selected'
                permissions          = $samplePermissionData
                events               = @('push', 'pull_request')
                single_file_paths    = @()
                created_at           = '2023-01-01T00:00:00Z'
                updated_at           = '2023-01-01T00:00:00Z'
                suspended_at         = $null
                suspended_by         = $null
                html_url             = 'https://github.com/settings/installations/12345'
            }
        }

        BeforeEach {
            Reset-GitHubConfig
        }

        It 'Should enrich permissions when ExpandAppPermissions is true' {
            Set-GitHubConfig -Name 'ExpandAppPermissions' -Value $true

            $installation = [GitHubAppInstallation]::new($sampleAppInstallationData)

            $installation.Permissions | Should -BeOfType [GitHubPermission]
            $installation.Permissions.Count | Should -BeGreaterThan 0

            # Check that we have enriched permission objects with metadata
            $issuePermission = $installation.Permissions | Where-Object { $_.Name -eq 'issues' }
            $issuePermission | Should -Not -BeNullOrEmpty
            $issuePermission.Value | Should -Be 'write'
            $issuePermission.DisplayName | Should -Be 'Issues'
            $issuePermission.Description | Should -Not -BeNullOrEmpty
        }

        It 'Should use raw permissions when ExpandAppPermissions is false' {
            Set-GitHubConfig -Name 'ExpandAppPermissions' -Value $false

            $installation = [GitHubAppInstallation]::new($sampleAppInstallationData)

            # Should have raw permission data, not enriched GitHubPermission objects
            $installation.Permissions | Should -Not -BeOfType [GitHubPermission]
            $installation.Permissions.issues | Should -Be 'write'
            $installation.Permissions.contents | Should -Be 'read'
            $installation.Permissions.actions | Should -Be 'write'
            $installation.Permissions.metadata | Should -Be 'read'
        }
    }
}
