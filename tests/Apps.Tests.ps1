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
[CmdletBinding()]
param()

Describe 'As a GitHub App - Enterprise (APP_ENT)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ENT_CLIENT_ID -PrivateKey $env:TEST_APP_ENT_PRIVATE_KEY
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Apps' {
        Context 'GitHub Apps' {
            It 'Can get a JWT for the app (APP_ENT)' {
                $jwt = Get-GitHubAppJSONWebToken -ClientId $env:TEST_APP_ENT_CLIENT_ID -PrivateKey $env:TEST_APP_ENT_PRIVATE_KEY
                Write-Verbose ($jwt | Format-Table | Out-String) -Verbose
                $jwt | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubApp - Can get app details (APP_ENT)' {
                $app = Get-GitHubApp
                Write-Verbose ($app | Format-Table | Out-String) -Verbose
                $app | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubAppInstallation - Can get app installations (APP_ENT)' {
                $installations = Get-GitHubAppInstallation
                Write-Verbose ($installations | Format-Table | Out-String) -Verbose
                $installations | Should -Not -BeNullOrEmpty
            }
            It 'New-GitHubAppInstallationAccessToken - Can get app installation access tokens (APP_ENT)' {
                $installations = Get-GitHubAppInstallation
                $installations | ForEach-Object {
                    $token = New-GitHubAppInstallationAccessToken -InstallationID $_.id
                    Write-Verbose ($token | Format-Table | Out-String) -Verbose
                    $token | Should -Not -BeNullOrEmpty
                }
            }
        }
        Context 'Webhooks' {
            It 'Can get the webhook configuration (APP_ENT)' {
                $webhooks = Get-GitHubAppWebhookConfiguration
                Write-Verbose ($webhooks | Format-Table | Out-String) -Verbose
                $webhooks | Should -Not -BeNullOrEmpty
            }
            It 'Can update the webhook configuration (APP_ENT)' {
                { Update-GitHubAppWebhookConfiguration -ContentType 'form' } | Should -Not -Throw
                { Update-GitHubAppWebhookConfiguration -ContentType 'json' } | Should -Not -Throw
            }
            It 'Can get webhook deliveries (APP_ENT)' {
                $deliveries = Get-GitHubAppWebhookDelivery
                Write-Verbose ($deliveries | Format-Table | Out-String) -Verbose
                $deliveries | Should -Not -BeNullOrEmpty
            }
            It 'Can redeliver a webhook delivery (APP_ENT)' {
                $deliveries = Get-GitHubAppWebhookDelivery | Select-Object -First 1
                { Invoke-GitHubAppWebhookReDelivery -ID $deliveries.id } | Should -Not -Throw
            }
        }
    }
}

Describe 'As a GitHub App - Organization (APP_ORG)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Apps' {
        Context 'GitHub Apps' {
            It 'Can get a JWT for the app (APP_ORG)' {
                $jwt = Get-GitHubAppJSONWebToken -ClientId $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
                Write-Verbose ($jwt | Format-Table | Out-String) -Verbose
                $jwt | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubApp - Can get app details (APP_ORG)' {
                $app = Get-GitHubApp
                Write-Verbose ($app | Format-Table | Out-String) -Verbose
                $app | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubAppInstallation - Can get app installations (APP_ORG)' {
                $installations = Get-GitHubAppInstallation
                Write-Verbose ($installations | Format-Table | Out-String) -Verbose
                $installations | Should -Not -BeNullOrEmpty
            }
            It 'New-GitHubAppInstallationAccessToken - Can get app installation access tokens (APP_ORG)' {
                $installations = Get-GitHubAppInstallation
                $installations | ForEach-Object {
                    $token = New-GitHubAppInstallationAccessToken -InstallationID $_.id
                    Write-Verbose ($token | Format-Table | Out-String) -Verbose
                    $token | Should -Not -BeNullOrEmpty
                }
            }
        }
        Context 'Webhooks' {
            It 'Can get the webhook configuration (APP_ORG)' {
                $webhooks = Get-GitHubAppWebhookConfiguration
                Write-Verbose ($webhooks | Format-Table | Out-String) -Verbose
                $webhooks | Should -Not -BeNullOrEmpty
            }
            It 'Can update the webhook configuration (APP_ORG)' {
                { Update-GitHubAppWebhookConfiguration -ContentType 'form' } | Should -Not -Throw
                { Update-GitHubAppWebhookConfiguration -ContentType 'json' } | Should -Not -Throw
            }
            It 'Can get webhook deliveries (APP_ORG)' {
                $deliveries = Get-GitHubAppWebhookDelivery
                Write-Verbose ($deliveries | Format-Table | Out-String) -Verbose
                $deliveries | Should -Not -BeNullOrEmpty
            }
            It 'Can redeliver a webhook delivery (APP_ORG)' {
                $deliveries = Get-GitHubAppWebhookDelivery | Select-Object -First 1
                { Invoke-GitHubAppWebhookReDelivery -ID $deliveries.id } | Should -Not -Throw
            }
        }
    }
}
