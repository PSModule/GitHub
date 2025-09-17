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
        It 'Should have ExpandAppPermissions in default config' {
            $config = Get-GitHubConfig
            $config.PSObject.Properties.Name | Should -Contain 'ExpandAppPermissions'
        }

        It 'Should default to false for GitHub Actions environment' {
            $expandValue = Get-GitHubConfig -Name 'ExpandAppPermissions'
            $expandValue | Should -Be $false
        }

        It 'Should allow a user to override the default and set it to true' {
            Set-GitHubConfig -Name ExpandAppPermissions -Value $true

            $expandValue = Get-GitHubConfig -Name 'ExpandAppPermissions'
            $expandValue | Should -Be $true
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
            $installation.Permissions | Should -BeOfType [GitHubPermission]
            foreach ($key in $samplePermissionData.PSObject.Properties.Name) {
                $installation.Permissions.PSObject.Properties.Name | Should -Contain $key
            }
        }
    }
}
