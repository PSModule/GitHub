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
BeforeAll {
    # DEFAULTS ACCROSS ALL TESTS
}

Describe 'Apps' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
        }

        # Tests for APP goes here
        if ($AuthType -eq 'APP') {
            Context 'GitHub Apps' {
                It 'Get-GitHubApp - Can get app details' {
                    $app = Get-GitHubApp
                    LogGroup 'App' {
                        Write-Host ($app | Format-Table | Out-String)
                    }
                    $app | Should -Not -BeNullOrEmpty
                }

                It 'Get-GitHubAppJSONWebToken - Can get a JWT for the app' {
                    $jwt = Get-GitHubAppJSONWebToken @connectParams
                    LogGroup 'JWT' {
                        Write-Host ($jwt | Format-Table | Out-String)
                    }
                    $jwt | Should -Not -BeNullOrEmpty
                }

                It 'Get-GitHubAppInstallation - Can get app installations' {
                    $installations = Get-GitHubAppInstallation
                    LogGroup 'Installations' {
                        Write-Host ($installations | Format-Table | Out-String)
                    }
                    $installations | Should -Not -BeNullOrEmpty
                }
                It 'New-GitHubAppInstallationAccessToken - Can get app installation access tokens' {
                    $installations = Get-GitHubAppInstallation
                    $installations | ForEach-Object {
                        $token = New-GitHubAppInstallationAccessToken -InstallationID $_.id
                        LogGroup 'Token' {
                            Write-Host ($token | Format-Table | Out-String)
                        }
                        $token | Should -Not -BeNullOrEmpty
                    }
                }
            }

            Context 'Webhooks' {
                It 'Get-GitHubAppWebhookConfiguration - Can get the webhook configuration' {
                    $webhookConfig = Get-GitHubAppWebhookConfiguration
                    LogGroup 'Webhook config' {
                        Write-Host ($webhookConfig | Format-Table | Out-String)
                    }
                    $webhookConfig | Should -Not -BeNullOrEmpty
                }

                It 'Update-GitHubAppWebhookConfiguration - Can update the webhook configuration' {
                    { Update-GitHubAppWebhookConfiguration -ContentType 'form' } | Should -Not -Throw
                    $webhookConfig = Get-GitHubAppWebhookConfiguration
                    LogGroup 'Webhook config - form' {
                        Write-Host ($webhookConfig | Format-Table | Out-String)
                    }
                    { Update-GitHubAppWebhookConfiguration -ContentType 'json' } | Should -Not -Throw
                    $webhookConfig = Get-GitHubAppWebhookConfiguration
                    LogGroup 'Webhook config - json' {
                        Write-Host ($webhookConfig | Format-Table | Out-String)
                    }
                }

                It 'Get-GitHubAppWebhookDelivery - Can get webhook deliveries' {
                    $deliveries = Get-GitHubAppWebhookDelivery
                    LogGroup 'Deliveries' {
                        Write-Host ($deliveries | Format-Table | Out-String)
                    }
                    $deliveries | Should -Not -BeNullOrEmpty
                }

                It 'Get-GitHubAppWebhookDelivery - Can redeliver a webhook delivery' {
                    $deliveries = Get-GitHubAppWebhookDelivery | Select-Object -First 1
                    LogGroup 'Delivery - redeliver' {
                        Write-Host ($deliveries | Format-Table | Out-String)
                    }
                    { Invoke-GitHubAppWebhookReDelivery -ID $deliveries.id } | Should -Not -Throw
                    LogGroup 'Delivery - redeliver' {
                        Write-Host ($deliveries | Format-Table | Out-String)
                    }
                }
            }
            It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                LogGroup 'Context' {
                    Write-Host ($context | Format-List | Out-String)
                }
            }
        }

        # Tests for runners goes here
        if ($Type -eq 'GitHub Actions') {}

        # Tests for IAT UAT and PAT goes here
    }
}

AfterAll {
    Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
}
