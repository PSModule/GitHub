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
            $permissionsList = [GitHubPermission]::NewPermissionList()
            LogGroup 'Context' {
                $context = Connect-GitHubAccount @connectParams -PassThru -Silent
                Write-Host "$($context | Format-List | Out-String)"
            }
            LogGroup 'Permissions' {
                Write-Host "$($context.Permissions | Format-Table | Out-String)"
            }
        }

        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            Write-Host ('-' * 60)
        }

        Context 'Non-GitHubApp' {
            It 'Get-GitHubApp - Get an app by slug' -Skip:($AuthType -eq 'APP') {
                $app = Get-GitHubApp -Slug 'github-actions'
                LogGroup 'App by slug' {
                    Write-Host ($app | Format-List | Out-String)
                }
                $app | Should -Not -BeNullOrEmpty
            }
        }

        Context 'GitHubApp' -Skip:($AuthType -ne 'APP') {
            BeforeAll {
                $app = Get-GitHubApp
                $installations = Get-GitHubAppInstallation
                $installationRequests = Get-GitHubAppInstallationRequest
                LogGroup 'All Installations (cached)' {
                    Write-Host ($installations | Out-String)
                }
                $installationSample = $installations | Select-Object -First 1
            }

            It 'Get-GitHubApp - Can get app details' {
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
                $app.Permissions.Count | Should -BeGreaterThan 0
                $app.Permissions | Should -BeOfType 'GitHubPermission'
                $app.Permissions.Name | Should -BeIn $permissionsList.Name
                $app.Events | Should -BeOfType 'string'
                $app.Installations | Should -Not -BeNullOrEmpty
            }

            It 'Get-GitHubAppInstallationRequest - Can get installation requests' {
                LogGroup 'Installation requests' {
                    Write-Host ($installationRequests | Format-List | Out-String)
                }
            }

            It 'Get-GitHubAppInstallation - Can get app installations' {
                $installations | Should -Not -BeNullOrEmpty
                foreach ($installation in $installations) {
                    LogGroup "Installation - $($installation.Target.Name)" {
                        Write-Host "$($installation | Format-List | Out-String)"
                    }
                    $installation | Should -BeOfType 'GitHubAppInstallation'
                    $installation.ID | Should -Not -BeNullOrEmpty
                    $installation.App | Should -BeOfType 'GitHubApp'
                    $installation.App.ClientID | Should -Be $app.ClientID
                    $installation.App.Slug | Should -Not -BeNullOrEmpty
                    $installation.Target | Should -BeOfType 'GitHubOwner'
                    $installation.Target | Should -Not -BeNullOrEmpty
                    $installation.Type | Should -BeIn @('Enterprise', 'Organization', 'User')
                    $installation.RepositorySelection | Should -Not -BeNullOrEmpty
                    $installation.Permissions.Count | Should -BeGreaterThan 0
                    $installation.Permissions | Should -BeOfType [GitHubPermission]
                    $installation.Permissions.Name | Should -BeIn $permissionsList.Name
                    $installation.Events | Should -BeOfType 'string'
                    $installation.CreatedAt | Should -Not -BeNullOrEmpty
                    $installation.UpdatedAt | Should -Not -BeNullOrEmpty
                    $installation.SuspendedAt | Should -BeNullOrEmpty
                    $installation.SuspendedBy | Should -BeOfType 'GitHubUser'
                    $installation.SuspendedBy | Should -BeNullOrEmpty
                    $installation.Status | Should -Not -BeNullOrEmpty
                    $installation.Status | Should -BeIn @('Ok', 'Outdated')
                }
            }

            It 'Get-GitHubAppInstallation -ID <ID>' {
                $installationSample | Should -Not -BeNullOrEmpty
                $installationByID = Get-GitHubAppInstallation -ID $installationSample.ID
                LogGroup "Installation By ID [$($installationSample.ID)]" {
                    Write-Host ($installationByID | Format-List | Out-String)
                }
                $installationByID | Should -Not -BeNullOrEmpty
                $installationByID | Should -BeOfType 'GitHubAppInstallation'
                $installationByID.ID | Should -Be $installationSample.ID
                $installationByID.Target.Name | Should -Be $installationSample.Target.Name
                $installationByID.Type | Should -Be $installationSample.Type
                $installationByID.Permissions.Count | Should -BeGreaterThan 0
            }

            It 'New-GitHubAppInstallationAccessToken - Can create installation access token' {
                $installationSample | Should -Not -BeNullOrEmpty
                $accessToken = New-GitHubAppInstallationAccessToken -ID $installationSample.ID
                LogGroup "Installation Access Token [$($installationSample.ID)]" {
                    Write-Host ($accessToken | Format-List | Out-String)
                }
                $accessToken | Should -Not -BeNullOrEmpty
                $accessToken.Token | Should -BeOfType [System.Security.SecureString]
                $accessToken.ExpiresAt | Should -BeGreaterThan (Get-Date)
                $accessToken.Permissions | Should -Not -BeNullOrEmpty
                $accessToken.RepositorySelection | Should -Not -BeNullOrEmpty
            }

            It 'Get-GitHubAppInstallation - <ownerType>' {
                $installation = $installations | Where-Object { ($_.Target.Name -eq $owner) -and ($_.Type -eq $ownerType) }
                LogGroup "Installation - $ownerType" {
                    Write-Host ($installation | Format-List | Out-String)
                }
                $installation | Should -Not -BeNullOrEmpty
                $installation | Should -BeOfType 'GitHubAppInstallation'
                $installation.ID | Should -Not -BeNullOrEmpty
                $installation.App | Should -BeOfType 'GitHubApp'
                $installation.App.ClientID | Should -Be $app.ClientID
                $installation.App.Slug | Should -Not -BeNullOrEmpty
                $installation.Target | Should -BeOfType 'GitHubOwner'
                $installation.Target | Should -Be $owner
                $installation.Type | Should -Be $ownerType
                $installation.RepositorySelection | Should -Not -BeNullOrEmpty
                $installation.Permissions.Count | Should -BeGreaterThan 0
                $installation.Permissions | Should -BeOfType [GitHubPermission]
                $installation.Permissions.Name | Should -BeIn $permissionsList.Name
                $installation.Events | Should -BeOfType 'string'
                $installation.CreatedAt | Should -Not -BeNullOrEmpty
                $installation.UpdatedAt | Should -Not -BeNullOrEmpty
                $installation.SuspendedAt | Should -BeNullOrEmpty
                $installation.SuspendedBy | Should -BeOfType 'GitHubUser'
                $installation.SuspendedBy | Should -BeNullOrEmpty
                $installation.Status | Should -Not -BeNullOrEmpty
                $installation.Status | Should -BeIn @('Ok', 'Outdated')
            }

            Context 'Webhooks' -Skip:($AuthType -ne 'APP') {
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

            Context 'Installation' -Skip:($AuthType -ne 'APP') {
                BeforeAll {
                    $githubApp = Get-GitHubApp
                    $config = Get-GitHubConfig
                    $permissionsList = [GitHubPermission]::NewPermissionList()
                    $installations = Get-GitHubAppInstallation
                    $installation = $installations | Where-Object { $_.Target.Name -eq $owner }
                    $installationContext = Connect-GitHubApp @connectAppParams -PassThru -Silent
                    LogGroup 'App' {
                        Write-Host "$($githubApp | Format-List | Out-String)"
                    }
                    LogGroup 'Config' {
                        Write-Host "$($config | Format-List | Out-String)"
                    }
                    LogGroup 'Installation' {
                        Write-Host "$($installation | Format-List | Out-String)"
                    }
                    LogGroup 'Permissions' {
                        Write-Host "$($installationContext.Permissions | Format-Table | Out-String)"
                    }
                    LogGroup 'Context' {
                        Write-Host "$($installationContext | Format-List | Out-String)"
                    }
                    LogGroup 'Context - -ListAvailable' {
                        Write-Host "$(Get-GitHubContext -ListAvailable | Format-List | Out-String)"
                    }
                }

                It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                    $installationContext | Should -BeOfType 'GitHubAppInstallationContext'
                    $installationContext.ClientID | Should -Be $githubApp.ClientID
                    $installationContext.TokenExpiresAt | Should -BeOfType [datetime]
                    $installationContext.InstallationID | Should -BeOfType [uint64]
                    $installationContext.InstallationID | Should -BeGreaterThan 0
                    $installationContext.Events | Should -BeOfType 'string'
                    $installationContext.InstallationType | Should -Be $ownertype
                    $installationContext.InstallationName | Should -Be $owner
                    $installationContext.ID | Should -Be "$($config.HostName)/$($githubApp.Slug)/$ownertype/$owner"
                    $installationContext.Name | Should -Be "$($config.HostName)/$($githubApp.Slug)/$ownertype/$owner"
                    $installationContext.DisplayName | Should -Be $githubApp.Name
                    $installationContext.Type | Should -Be 'Installation'
                    $installationContext.HostName | Should -Be $config.HostName
                    $installationContext.ApiBaseUri | Should -Be $config.ApiBaseUri
                    $installationContext.ApiVersion | Should -Be $config.ApiVersion
                    $installationContext.AuthType | Should -Be 'IAT'
                    $installationContext.NodeID | Should -Not -BeNullOrEmpty
                    $installationContext.DatabaseID | Should -Not -BeNullOrEmpty
                    $installationContext.UserName | Should -Be $githubApp.Slug
                    $installationContext.Token | Should -BeOfType [System.Security.SecureString]
                    $installationContext.TokenType | Should -Be 'ghs'
                    $installationContext.HttpVersion | Should -Be $config.HttpVersion
                    $installationContext.PerPage | Should -Be $config.PerPage
                    $installationContext.Permissions.Count | Should -BeGreaterThan 0
                    $installationContext.Permissions | Should -BeOfType [GitHubPermission]
                    $installationContext.Permissions.Name | Should -BeIn $permissionsList.Name
                    $installationContext.Events | Should -BeOfType 'string'
                }

                It 'Connect-GitHubApp - TokenExpiresAt and TokenExpiresIn properties should be calculated correctly' {
                    $installationContext.TokenExpiresAt | Should -BeOfType [DateTime]
                    $installationContext.TokenExpiresAt | Should -BeGreaterThan ([DateTime]::Now)
                    $installationContext.TokenExpiresIn | Should -BeOfType [TimeSpan]
                    $installationContext.TokenExpiresIn.TotalSeconds | Should -BeGreaterThan 0
                    $installationContext.TokenExpiresIn.TotalMinutes | Should -BeGreaterThan 0
                    $installationContext.TokenExpiresIn.TotalMinutes | Should -BeLessOrEqual 60
                }

                It 'Revoked GitHub App token should fail on API call' -Skip:($TokenType -eq 'GITHUB_TOKEN') {
                    $org = Get-GitHubOrganization -Name PSModule -Context $installationContext
                    $org | Should -Not -BeNullOrEmpty
                    $installationContext | Disconnect-GitHub

                    {
                        $params = @{
                            Method         = 'Get'
                            Uri            = "$($installationContext.ApiBaseUri)/orgs/PSModule"
                            Authentication = 'Bearer'
                            Token          = $installationContext.token
                        }
                        Invoke-RestMethod @params
                    } | Should -Throw
                }

                It 'Connect-GitHubApp - Connects using -ID parameter for a single installation' {
                    $installationId = $installation.ID
                    $installationId | Should -BeGreaterThan 0

                    $installationIDContext = Connect-GitHubApp -ID $installationId -PassThru -Silent
                    LogGroup "Connect-GitHubApp -ID $installationId" {
                        Write-Host ($installationIDContext | Format-List | Out-String)
                    }

                    $installationIDContext | Should -BeOfType 'GitHubAppInstallationContext'
                    $installationIDContext.ClientID | Should -Be $context.ClientID
                    $installationIDContext.AuthType | Should -Be 'IAT'
                    $installationIDContext.Token | Should -BeOfType [System.Security.SecureString]
                    $installationIDContext.TokenType | Should -Be 'ghs'
                }

                It 'Connect-GitHubApp - Connects using multiple -ID parameters' {
                    $multiInstallations = $installations | Select-Object -First 2
                    $ids = $multiInstallations.ID
                    $ids.Count | Should -BeGreaterThan 1

                    $contexts = Connect-GitHubApp -ID $ids -PassThru
                    $contexts | Should -Not -BeNullOrEmpty
                    $contexts.Count | Should -Be $ids.Count
                    foreach ($c in $contexts) {
                        $c | Should -BeOfType 'GitHubAppInstallationContext'
                        $c.InstallationID | Should -BeIn $ids
                        $c.AuthType | Should -Be 'IAT'
                        $c.Token | Should -BeOfType [System.Security.SecureString]
                    }
                }

                It 'Connect-GitHubApp - Connects using installation objects from the pipeline' {
                    $pipelineInstallations = $installations | Select-Object -First 2
                    if (-not $pipelineInstallations) {
                        Set-ItResult -Skipped -Because 'No installations available to test pipeline parameter set.'
                        return
                    }
                    $contexts = $pipelineInstallations | Connect-GitHubApp -PassThru
                    $contexts | Should -Not -BeNullOrEmpty
                    foreach ($pi in $pipelineInstallations) {
                        ($contexts | Where-Object InstallationID -EQ $pi.ID) | Should -Not -BeNullOrEmpty
                    }
                    foreach ($c in $contexts) {
                        $c | Should -BeOfType 'GitHubAppInstallationContext'
                        $c.AuthType | Should -Be 'IAT'
                        $c.Token | Should -BeOfType [System.Security.SecureString]
                    }
                }
            }
        }
    }
}
