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

Describe 'Apps' {
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

        # Tests for APP goes here
        if ($AuthType -eq 'APP') {
            Context 'GitHub Apps' {
                It 'Get-GitHubApp - Can get app details' {
                    $app = Get-GitHubApp
                    LogGroup 'App' {
                        Write-Host ($app | Format-List | Out-String)
                    }
                    $app | Should -Not -BeNullOrEmpty
                    $app | Should -BeOfType 'GitHubApp'
                    $app.ID | Should -Not -BeNullOrEmpty
                    $app.ClientID | Should -Not -BeNullOrEmpty
                    $app.Slug | Should -Not -BeNullOrEmpty
                    $app.NodeID | Should -Not -BeNullOrEmpty
                    $app.Owner | Should -BeOfType 'GitHubOwner'
                    $app.Name | Should -Not -BeNullOrEmpty
                    $app.Description | Should -Not -BeNullOrEmpty
                    $app.ExternalUrl | Should -Not -BeNullOrEmpty
                    $app.Url | Should -Not -BeNullOrEmpty
                    $app.CreatedAt | Should -Not -BeNullOrEmpty
                    $app.UpdatedAt | Should -Not -BeNullOrEmpty
                    $app.Permissions | Should -BeOfType 'PSCustomObject'
                    $app.Events | Should -BeOfType 'string'
                    $app.Installations | Should -Not -BeNullOrEmpty
                }

                It 'Get-GitHubAppJSONWebToken - Can get a JWT for the app' {
                    $jwt = Get-GitHubAppJSONWebToken @connectParams
                    LogGroup 'JWT' {
                        Write-Host ($jwt | Format-Table | Out-String)
                    }
                    $jwt | Should -Not -BeNullOrEmpty
                }

                It 'Get-GitHubAppInstallationRequest - Can get installation requests' {
                    $installationRequests = Get-GitHubAppInstallationRequest
                    LogGroup 'Installation requests' {
                        Write-Host ($installationRequests | Format-List | Out-String)
                    }
                }

                It 'Get-GitHubAppInstallation - Can get app installations' {
                    $githubApp = Get-GitHubApp
                    $installations = Get-GitHubAppInstallation
                    LogGroup 'Installations' {
                        Write-Host ($installations | Format-List | Out-String)
                    }
                    $installations | Should -Not -BeNullOrEmpty
                    foreach ($installation in $installations) {
                        $installation | Should -BeOfType 'GitHubAppInstallation'
                        $installation.ID | Should -Not -BeNullOrEmpty
                        $installation.App | Should -BeOfType 'GitHubApp'
                        $installation.App.ClientID | Should -Be $githubApp.ClientID
                        $installation.App.AppID | Should -Not -BeNullOrEmpty
                        $installation.App.Slug | Should -Not -BeNullOrEmpty
                        $installation.Target | Should -BeOfType 'GitHubOwner'
                        $installation.Target | Should -Not -BeNullOrEmpty
                        $installation.Type | Should -BeIn @('Enterprise', 'Organization', 'User')
                        $installation.RepositorySelection | Should -Not -BeNullOrEmpty
                        $installation.Permissions | Should -BeOfType 'PSCustomObject'
                        $installation.Events | Should -BeOfType 'string'
                        $installation.CreatedAt | Should -Not -BeNullOrEmpty
                        $installation.UpdatedAt | Should -Not -BeNullOrEmpty
                        $installation.SuspendedAt | Should -BeNullOrEmpty
                        $installation.SuspendedBy | Should -BeOfType 'GitHubUser'
                        $installation.SuspendedBy | Should -BeNullOrEmpty
                    }
                }

                It 'New-GitHubAppInstallationAccessToken - Can get app installation access tokens' {
                    $installations = Get-GitHubAppInstallation
                    LogGroup 'Tokens' {
                        $installations | ForEach-Object {
                            $token = New-GitHubAppInstallationAccessToken -InstallationID $_.id
                            Write-Host ($token | Format-List | Out-String)
                        }
                        $token | Should -Not -BeNullOrEmpty
                    }
                }

                It 'Get-GitHubAppInstallation - <ownerType>' {
                    $githubApp = Get-GitHubApp
                    $installation = Get-GitHubAppInstallation | Where-Object { ($_.Target.Name -eq $owner) -and ($_.Type -eq $ownerType) }
                    LogGroup "Installation - $ownerType" {
                        Write-Host ($installation | Format-List | Out-String)
                    }
                    $installation | Should -Not -BeNullOrEmpty
                    $installation | Should -BeOfType 'GitHubAppInstallation'
                    $installation.ID | Should -Not -BeNullOrEmpty
                    $installation.App | Should -BeOfType 'GitHubApp'
                    $installation.App.ClientID | Should -Be $githubApp.ClientID
                    $installation.App.AppID | Should -Not -BeNullOrEmpty
                    $installation.App.Slug | Should -Not -BeNullOrEmpty
                    $installation.Target | Should -BeOfType 'GitHubOwner'
                    $installation.Target | Should -Be $owner
                    $installation.Type | Should -Be $ownerType
                    $installation.RepositorySelection | Should -Not -BeNullOrEmpty
                    $installation.Permissions | Should -BeOfType 'PSCustomObject'
                    $installation.Events | Should -BeOfType 'string'
                    $installation.CreatedAt | Should -Not -BeNullOrEmpty
                    $installation.UpdatedAt | Should -Not -BeNullOrEmpty
                    $installation.SuspendedAt | Should -BeNullOrEmpty
                    $installation.SuspendedBy | Should -BeOfType 'GitHubUser'
                    $installation.SuspendedBy | Should -BeNullOrEmpty
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

            Context 'Installation' {
                BeforeAll {
                    $githubApp = Get-GitHubApp
                    $config = Get-GitHubConfig
                    $context = Connect-GitHubApp @connectAppParams -PassThru -Silent
                    LogGroup 'Context' {
                        Write-Host ($context | Format-List | Out-String)
                    }
                }

                It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                    $context | Should -BeOfType 'InstallationGitHubContext'
                    $context.ClientID | Should -Be $githubApp.ClientID
                    $context.TokenExpirationDate | Should -BeOfType [datetime]
                    $context.InstallationID | Should -BeOfType [uint64]
                    $context.InstallationID | Should -BeGreaterThan 0
                    $context.Permissions | Should -BeOfType [PSCustomObject]
                    $context.Events | Should -BeOfType 'string'
                    $context.InstallationType | Should -Be $ownertype
                    $context.InstallationName | Should -Be $owner
                    $context.ID | Should -Be "$($config.HostName)/$($githubApp.Slug)/$ownertype/$owner"
                    $context.Name | Should -Be "$($config.HostName)/$($githubApp.Slug)/$ownertype/$owner"
                    $context.DisplayName | Should -Be $githubApp.Name
                    $context.Type | Should -Be 'Installation'
                    $context.HostName | Should -Be $config.HostName
                    $context.ApiBaseUri | Should -Be $config.ApiBaseUri
                    $context.ApiVersion | Should -Be $config.ApiVersion
                    $context.AuthType | Should -Be 'IAT'
                    $context.NodeID | Should -Not -BeNullOrEmpty
                    $context.DatabaseID | Should -Not -BeNullOrEmpty
                    $context.UserName | Should -Be $githubApp.Slug
                    $context.Token | Should -BeOfType [System.Security.SecureString]
                    $context.TokenType | Should -Be 'ghs'
                    $context.HttpVersion | Should -Be $config.HttpVersion
                    $context.PerPage | Should -Be $config.PerPage
                }

                It 'Revoked GitHub App token should fail on API call' -Skip:($TokenType -eq 'GITHUB_TOKEN') {
                    $org = Get-GitHubOrganization -Name PSModule -Context $context
                    $org | Should -Not -BeNullOrEmpty
                    $context | Disconnect-GitHub

                    {
                        Invoke-RestMethod -Method Get -Uri "$($context.ApiBaseUri)/orgs/PSModule" -Authentication Bearer -Token $context.token
                    } | Should -Throw
                }
            }
        }

        # Tests for IAT UAT and PAT goes here
        It 'Get-GitHubApp - Get an app by slug' -Skip:($AuthType -eq 'APP') {
            $app = Get-GitHubApp -Slug 'github-actions'
            LogGroup 'App by slug' {
                Write-Host ($app | Format-List | Out-String)
            }
            $app | Should -Not -BeNullOrEmpty
        }
    }
}
