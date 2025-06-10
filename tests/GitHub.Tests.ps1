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

Describe 'Auth' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            Write-Host ('-' * 60)
        }

        It 'Connect-GitHubAccount - Connects using the provided credentials' {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
        }

        It 'Connect-GitHubAccount - Connects using the provided credentials - Double' {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
        }

        It 'Connect-GitHubAccount - Connects using the provided credentials - Relog' {
            Disconnect-GitHub -Silent
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
        }

        It 'Switch-GitHubContext - Sets the default context' {
            $context = Get-GitHubContext
            Switch-GitHubContext -Context $context
            $context = Get-GitHubContext
            $context | Should -Not -BeNullOrEmpty
        }

        It 'Connect-GitHubAccount - Connects using the provided credentials + AutoloadInstallations' -Skip:($AuthType -ne 'APP') {
            LogGroup 'Connect-Github' {
                $context = Connect-GitHubAccount @connectParams -PassThru -Silent -AutoloadInstallations -Debug -Verbose
            }
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
        }

        It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' -Skip:($AuthType -ne 'APP') {
            LogGroup 'Connect-GithubApp' {
                $contexts = Connect-GitHubApp -PassThru -Silent -Debug -Verbose
            }
            LogGroup 'Contexts' {
                Write-Host ($contexts | Format-List | Out-String)
            }
            $contexts | Should -Not -BeNullOrEmpty
        }

        It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' -Skip:($AuthType -ne 'APP') {
            LogGroup 'Connect-GithubApp' {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent -Debug -Verbose
            }
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
        }

        # Tests for runners goes here
        if ($Type -eq 'GitHub Actions') {}

        # Tests for IAT UAT and PAT goes here
        It 'Connect-GitHubAccount - Connects to GitHub CLI on runners' {
            [string]::IsNullOrEmpty($(gh auth token)) | Should -Be $false
        }
        It 'Get-GitHubViewer - Gets the logged in context' {
            $viewer = Get-GitHubViewer
            LogGroup 'Viewer' {
                Write-Host ($viewer | Format-List | Out-String)
            }
            $viewer | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubContext - Gets the default context' {
            $context = Get-GitHubContext
            LogGroup 'Default context' {
                Write-Host ($viewer | Format-List | Out-String)
            }
        }

        It 'Get-GitHubContext - List all contexts' {
            $contexts = Get-GitHubContext -ListAvailable
            LogGroup 'Contexts' {
                Write-Host ($contexts | Format-List | Out-String)
            }
            $contexts.count | Should -BeGreaterOrEqual 1
        }

        It 'Disconnect-GitHubAccount - Disconnects all contexts' {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            (Get-GitHubContext -ListAvailable).count | Should -Be 0
        }

        It 'Get-GitHubContext - Does not fail when there are 0 contexts' {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            { Get-GitHubContext } | Should -Not -Throw
            $contexts = Get-GitHubContext
            $contexts | Should -BeNullOrEmpty
        }
    }
}

Describe 'GitHub' {
    Context 'Config' {
        It 'Get-GitHubConfig - Gets the module configuration' {
            $config = Get-GitHubConfig
            Write-Host ($config | Format-Table | Out-String)
            $config | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubConfig - Gets a configuration item by name' {
            $config = Get-GitHubConfig
            $config.AccessTokenGracePeriodInHours | Should -Be 4
            $config.HostName | Should -Be 'github.com'
            $config.HttpVersion | Should -Be '2.0'
            $config.PerPage | Should -Be 100
        }
        It 'Set-GitHubConfig - Sets a configuration item' {
            Set-GitHubConfig -Name 'HostName' -Value 'msx.ghe.com'
            Get-GitHubConfig -Name 'HostName' | Should -Be 'msx.ghe.com'
        }
        It 'Remove-GitHubConfig - Removes a configuration item' {
            Remove-GitHubConfig -Name 'HostName'
            Get-GitHubConfig -Name 'HostName' | Should -BeNullOrEmpty
        }
        It 'Reset-GitHubConfig - Resets the module configuration' {
            Set-GitHubConfig -Name HostName -Value 'msx.ghe.com'
            Get-GitHubConfig -Name HostName | Should -Be 'msx.ghe.com'
            Reset-GitHubConfig
            Get-GitHubConfig -Name HostName | Should -Be 'github.com'
        }
    }
    Context 'Actions' {
        It 'Get-GitHubEventData - Gets data about the event that triggered the workflow' {
            $workflow = Get-GitHubEventData
            Write-Host ($workflow | Format-List | Out-String)
            $workflow | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRunnerData - Gets data about the runner that is running the workflow' {
            $workflow = Get-GitHubRunnerData
            Write-Host ($workflow | Format-List | Out-String)
            $workflow | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Status' -ForEach @('Public', 'Europe', 'Australia') {
        It 'Get-GitHubScheduledMaintenance - Gets scheduled maintenance for <_>' {
            { Get-GitHubScheduledMaintenance -Stamp $_ } | Should -Not -Throw
        }
        It 'Get-GitHubScheduledMaintenance - Gets active maintenance for <_>' {
            { Get-GitHubScheduledMaintenance -Stamp $_ -Active } | Should -Not -Throw
        }
        It 'Get-GitHubScheduledMaintenance - Gets upcoming maintenance for <_>' {
            { Get-GitHubScheduledMaintenance -Stamp $_ -Upcoming } | Should -Not -Throw
        }
        It 'Get-GitHubStatus - Gets all status for <_>' {
            { Get-GitHubStatus -Stamp $_ } | Should -Not -Throw
        }
        It 'Get-GitHubStatus - Gets summary status for <_>' {
            { Get-GitHubStatus -Stamp $_ -Summary } | Should -Not -Throw
        }
        It 'Get-GitHubStatusComponent - Gets the status of GitHub components for <_>' {
            { Get-GitHubStatusComponent -Stamp $_ } | Should -Not -Throw
        }
        It 'Get-GitHubStatusIncident - Gets the status of all GitHub incidents for <_>' {
            { Get-GitHubStatusIncident -Stamp $_ } | Should -Not -Throw
        }
        It 'Get-GitHubStatusIncident - Gets the status of unresolved GitHub incidents for <_>' {
            { Get-GitHubStatusIncident -Stamp $_ -Unresolved } | Should -Not -Throw
        }
    }
    Context 'Commands' {
        It 'Start-GitHubLogGroup - Should not throw' {
            {
                Start-GitHubLogGroup 'MyGroup'
            } | Should -Not -Throw
        }
        It 'Stop-LogGroup - Should not throw' {
            {
                Stop-GitHubLogGroup
            } | Should -Not -Throw
        }
        It 'Set-GitHubLogGroup - Should not throw' {
            {
                Set-GitHubLogGroup -Name 'MyGroup' -ScriptBlock {
                    Get-ChildItem env: | Select-Object Name, Value | Format-Table -AutoSize
                }
            } | Should -Not -Throw
        }
        It 'LogGroup - Should not throw' {
            {
                LogGroup 'MyGroup' {
                    Get-ChildItem env: | Select-Object Name, Value | Format-Table -AutoSize
                }
            } | Should -Not -Throw
        }
        It 'Add-GitHubMask - Should not throw' {
            {
                Add-GitHubMask -Value 'taskmaster'
            } | Should -Not -Throw
        }
        It 'Add-GitHubSystemPath - Should not throw' {
            {
                Add-GitHubSystemPath -Path $pwd.ToString()
            } | Should -Not -Throw
            Get-Content $env:GITHUB_PATH -Raw | Should -BeLike "*$($pwd.ToString())*"
        }
        It 'Disable-GitHubCommand - Should not throw' {
            {
                Disable-GitHubCommand -String 'MyString'
            } | Should -Not -Throw
        }
        It 'Enable-GitHubCommand - Should not throw' {
            {
                Enable-GitHubCommand -String 'MyString'
            } | Should -Not -Throw
        }
        It 'Set-GitHubNoCommandGroup - Should not throw' {
            {
                Set-GitHubNoCommandGroup {
                    Write-Output 'Hello, World!'
                }
            } | Should -Not -Throw
        }
        It 'Set-GitHubOutput + Simple string - Should not throw' {
            {
                Set-GitHubOutput -Name 'MyOutput' -Value 'MyValue'
            } | Should -Not -Throw
            (Get-GitHubOutput).MyOutput | Should -Be 'MyValue'
        }
        It 'Set-GitHubOutput + Multiline string - Should not throw' {
            {
                Set-GitHubOutput -Name 'MyOutput' -Value @'
This is a multiline
string
'@
            } | Should -Not -Throw
            (Get-GitHubOutput).MyOutput | Should -Be @'
This is a multiline
string
'@
        }
        It 'Set-GitHubOutput + SecureString - Should not throw' {
            {
                $secret = 'MyValue' | ConvertTo-SecureString -AsPlainText -Force
                Set-GitHubOutput -Name 'MySecret' -Value $secret
            } | Should -Not -Throw
            (Get-GitHubOutput).MySecret | Should -Be 'MyValue'
        }
        It 'Set-GitHubOutput + Object - Should not throw' {
            {
                $jupiter = [PSCustomObject]@{
                    Name          = 'Jupiter'
                    NumberOfMoons = 79
                    Moons         = @(@{ Name = 'Io'; Radius = 1821 }, @{ Name = 'Europa'; Radius = 1560 })
                    NumberOfRings = 4
                    RockyPlanet   = $false
                    Neighbors     = @('Mars', 'Saturn')
                    SomethingElse = [PSCustomObject]@{
                        Name  = 'Something'
                        Value = 'Else'
                    }
                }
                Set-GitHubOutput -Name 'Jupiter' -Value $jupiter
            } | Should -Not -Throw
            (Get-GitHubOutput).Config | Should -BeLike ''
        }
        It 'Get-GitHubOutput - Should not throw' {
            {
                Get-GitHubOutput
            } | Should -Not -Throw
            Write-Host (Get-GitHubOutput | Format-List | Out-String)
        }
        It 'Set-GitHubEnvironmentVariable - Should not throw' {
            {
                Set-GitHubEnvironmentVariable -Name 'MyName' -Value 'MyValue'
            } | Should -Not -Throw
            Get-Content $env:GITHUB_ENV -Raw | Should -BeLike '*MyName*MyValue*'
        }
        It 'Set-GitHubStepSummary - Should not throw' {
            {
                Set-GitHubStepSummary -Summary 'MySummary'
            } | Should -Not -Throw
        }
        It 'Write-GitHub* - Should not throw' {
            { Write-GitHubDebug 'Debug' } | Should -Not -Throw
            { Write-GitHubError 'Error' } | Should -Not -Throw
            { Write-GitHubNotice 'Notice' } | Should -Not -Throw
            { Write-GitHubWarning 'Warning' } | Should -Not -Throw
            { Write-GitHubLog 'Log' } | Should -Not -Throw
            { Write-GitHubLog 'Colored Log' -ForegroundColor Green } | Should -Not -Throw
        }
    }
    Context 'IssueParser' {
        BeforeAll {
            $issueTestFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'Data/IssueForm.md'
            Write-Host "Reading from $issueTestFilePath"
            $content = Get-Content -Path $issueTestFilePath -Raw
            Write-Host ($content | Out-String)
            $dataObject = $content | ConvertFrom-IssueForm
            Write-Host 'As PSCustomObject'
            Write-Host ($dataObject | Format-List | Out-String)
            $dataHashtable = $content | ConvertFrom-IssueForm -AsHashtable
            Write-Host 'As Hashtable'
            Write-Host ($dataHashtable | Out-String)
        }

        It 'ConvertFrom-IssueForm - Should return a PSCustomObject' {
            $dataObject | Should -BeOfType 'PSCustomObject'
        }

        It 'ConvertFrom-IssueForm -AsHashtable - Should return a hashtable' {
            $dataHashtable | Should -BeOfType 'hashtable'
        }

        It "'Type with spaces' should contain 'Action'" {
            Write-Host ($dataHashtable['Type with spaces'] | Out-String)
            $dataHashtable.Keys | Should -Contain 'Type with spaces'
            $dataHashtable['Type with spaces'] | Should -Be 'Action'
        }

        It "'Multiline' should contain a multiline string with 3 lines" {
            Write-Host ($dataHashtable['Multiline'] | Out-String)
            $dataHashtable.Keys | Should -Contain 'Multiline'
            $dataHashtable['Multiline'] | Should -Be @'
test
is multi
line
'@
        }

        It "'OS' should contain a hashtable with 3 items" {
            Write-Host ($dataHashtable['OS'] | Out-String)
            $dataHashtable.Keys | Should -Contain 'OS'
            $dataHashtable['OS'].Windows | Should -BeTrue
            $dataHashtable['OS'].Linux | Should -BeTrue
            $dataHashtable['OS'].Mac | Should -BeFalse
        }
    }
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
                        Write-Host ($app | Format-Table | Out-String)
                    }
                    $app | Should -Not -BeNullOrEmpty
                    $app | Should -BeOfType 'GitHubApp'
                    $app.ID | Should -Not -BeNullOrEmpty
                    $app.ClientID | Should -Not -BeNullOrEmpty
                    $app.AppID | Should -Not -BeNullOrEmpty
                    $app.Slug | Should -Not -BeNullOrEmpty
                    $app.NodeID | Should -Not -BeNullOrEmpty
                    $app.Owner | Should -BeOfType 'GitHubOwner'
                    $app.Name | Should -Not -BeNullOrEmpty
                    $app.Description | Should -Not -BeNullOrEmpty
                    $app.ExternalUrl | Should -Not -BeNullOrEmpty
                    $app.Url | Should -Not -BeNullOrEmpty
                    $app.CreatedAt | Should -Not -BeNullOrEmpty
                    $app.UpdatedAt | Should -Not -BeNullOrEmpty
                    $app.Permissions | Should -Not -BeNullOrEmpty
                    $app.Events | Should -BeOfType 'Object[]'
                    $app.Installations | Should -Not -BeNullOrEmpty
                }
                # It 'Get-GitHubApp - Get an app by slug' {
                #     $app = Get-GitHubApp -Name 'github-actions'
                #     LogGroup 'App by slug' {
                #         Write-Host ($app | Format-Table | Out-String)
                #     }
                #     $app | Should -Not -BeNullOrEmpty
                # }

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
                        Write-Host ($installations | Format-List | Out-String)
                    }
                    $installations | Should -Not -BeNullOrEmpty
                    $githubApp = Get-GitHubApp
                    foreach ($installation in $installations) {
                        $installation | Should -BeOfType 'GitHubAppInstallation'
                        $installation.ID | Should -Not -BeNullOrEmpty
                        $installation.App | Should -BeOfType 'GitHubApp'
                        $installation.App.ClientID | Should -Be $githubApp.ClientID
                        $installation.App.AppID | Should -Not -BeNullOrEmpty
                        $installation.App.AppSlug | Should -Not -BeNullOrEmpty
                        $installation.Target | Should -BeOfType 'GitHubOwner'
                        $installation.Type | Should -Not -BeNullOrEmpty
                        $installation.RepositorySelection | Should -Not -BeNullOrEmpty
                        $installation.Permissions | Should -Not -BeNullOrEmpty
                        $installation.Events | Should -BeOfType 'Object[]'
                        $installation.CreatedAt | Should -Not -BeNullOrEmpty
                        $installation.UpdatedAt | Should -Not -BeNullOrEmpty
                        $installation.SuspendedAt | Should -BeNullOrEmpty
                        $installation.SuspendedBy | Should -BeOfType 'GitHubUser'
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

Describe 'API' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            Write-Host ('-' * 60)
        }

        # Tests for APP goes here
        if ($AuthType -eq 'APP') {
            It 'Invoke-GitHubAPI - Gets the app details' {
                {
                    $app = Invoke-GitHubAPI -ApiEndpoint '/app'
                    LogGroup 'App' {
                        Write-Host ($app | Format-Table | Out-String)
                    }
                } | Should -Not -Throw
            }

            It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                LogGroup 'Context' {
                    Write-Host ($context | Format-List | Out-String)
                }
                $context | Should -Not -BeNullOrEmpty
            }
        }

        # Tests for runners goes here
        if ($Type -eq 'GitHub Actions') {}

        # Tests for IAT UAT and PAT goes here
        Context 'API' {
            It 'Invoke-GitHubAPI - Gets the rate limits directly using APIEndpoint' {
                {
                    $rateLimit = Invoke-GitHubAPI -ApiEndpoint '/rate_limit'
                    LogGroup 'RateLimit' {
                        Write-Host ($rateLimit | Format-Table | Out-String)
                    }
                } | Should -Not -Throw
            }

            It 'Invoke-GitHubAPI - Gets the rate limits directly using Uri' {
                {
                    $rateLimit = Invoke-GitHubAPI -Uri ($context.ApiBaseUri + '/rate_limit')
                    LogGroup 'RateLimit' {
                        Write-Host ($rateLimit | Format-Table | Out-String)
                    }
                } | Should -Not -Throw
            }

            It 'Invoke-GitHubGraphQLQuery - Gets the viewer' {
                {
                    $viewer = Invoke-GitHubGraphQLQuery -Query 'query { viewer { login } }'
                    LogGroup 'Viewer' {
                        Write-Host ($viewer | Format-Table | Out-String)
                    }
                } | Should -Not -Throw
            }
        }

        Context 'Meta' {
            It 'Get-GitHubRoot - Gets the GitHub API Root' {
                $root = Get-GitHubRoot
                LogGroup 'Root' {
                    Write-Host ($root | Format-Table | Out-String)
                }
                $root | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubApiVersion - Gets all API versions' {
                $apiVersion = Get-GitHubApiVersion
                LogGroup 'ApiVersion' {
                    Write-Host ($apiVersion | Format-Table | Out-String)
                }
                $apiVersion | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubMeta - Gets GitHub meta information' {
                $meta = Get-GitHubMeta
                LogGroup 'Meta' {
                    Write-Host ($meta | Format-Table | Out-String)
                }
                $meta | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubOctocat - Gets the Octocat' {
                $octocat = Get-GitHubOctocat
                LogGroup 'Octocat' {
                    Write-Host ($octocat | Format-Table | Out-String)
                }
                $octocat | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubZen - Gets the Zen of GitHub' {
                $zen = Get-GitHubZen
                LogGroup 'Zen' {
                    Write-Host ($zen | Format-Table | Out-String)
                }
                $zen | Should -Not -BeNullOrEmpty
            }
        }

        Context 'Rate-Limit' {
            It 'Get-GitHubRateLimit - Gets the rate limit status for the authenticated user' {
                $rateLimit = Get-GitHubRateLimit
                LogGroup 'RateLimit' {
                    Write-Host ($rateLimit | Format-Table | Out-String)
                }
                $rateLimit | Should -Not -BeNullOrEmpty
            }
        }

        Context 'License' {
            It 'Get-GitHubLicense - Gets a list of all popular license templates' {
                $licenseList = Get-GitHubLicense
                LogGroup 'Licenses' {
                    Write-Host ($licenseList | Format-Table | Out-String)
                }
                $licenseList | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubLicense - Gets a spesific license' {
                $mitLicense = Get-GitHubLicense -Name 'mit'
                LogGroup 'MIT License' {
                    Write-Host ($mitLicense | Format-Table | Out-String)
                }
                $mitLicense | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubLicense - Gets a license from a repository' {
                $githubLicense = Get-GitHubLicense -Owner 'PSModule' -Repository 'GitHub'
                LogGroup 'GitHub License' {
                    Write-Host ($githubLicense | Format-Table | Out-String)
                }
                $githubLicense | Should -Not -BeNullOrEmpty
            }
        }

        Context 'GitIgnore' {
            It 'Get-GitHubGitignore - Gets a list of all gitignore templates names' {
                $gitIgnoreList = Get-GitHubGitignore
                LogGroup 'GitIgnoreList' {
                    Write-Host ($gitIgnoreList | Format-Table | Out-String)
                }
                $gitIgnoreList | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubGitignore - Gets a gitignore template' {
                $vsGitIgnore = Get-GitHubGitignore -Name 'VisualStudio'
                LogGroup 'Visual Studio GitIgnore' {
                    Write-Host ($vsGitIgnore | Format-Table | Out-String)
                }
                $vsGitIgnore | Should -Not -BeNullOrEmpty
            }
        }

        Context 'Markdown' {
            It 'Get-GitHubMarkdown - Gets the rendered markdown for provided text' {
                $markdown = Get-GitHubMarkdown -Text 'Hello, World!'
                LogGroup 'Markdown' {
                    Write-Host ($markdown | Format-Table | Out-String)
                }
                $markdown | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubMarkdown - Gets the rendered markdown for provided text using GitHub Formated Markdown' {
                $gfmMarkdown = Get-GitHubMarkdown -Text 'Hello, World!' -Mode gfm
                LogGroup 'GFM Markdown' {
                    Write-Host ($gfmMarkdown | Format-Table | Out-String)
                }
                $gfmMarkdown | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubMarkdownRaw - Gets the raw rendered markdown for provided text' {
                $rawMarkdown = Get-GitHubMarkdownRaw -Text 'Hello, World!'
                LogGroup 'Raw Markdown' {
                    Write-Host ($rawMarkdown | Format-Table | Out-String)
                }
                $rawMarkdown | Should -Not -BeNullOrEmpty
            }
        }

        Context 'Git' {
            It "Get-GitHubGitConfig gets the 'local' (default) Git configuration" {
                $gitConfig = Get-GitHubGitConfig
                LogGroup 'GitConfig' {
                    Write-Host ($gitConfig | Format-List | Out-String)
                }
                $gitConfig | Should -Not -BeNullOrEmpty
            }
            It "Get-GitHubGitConfig gets the 'global' Git configuration" {
                git config --global advice.pushfetchfirst false
                $gitConfig = Get-GitHubGitConfig -Scope 'global'
                LogGroup 'GitConfig - Global' {
                    Write-Host ($gitConfig | Format-List | Out-String)
                }
                $gitConfig | Should -Not -BeNullOrEmpty
            }
            It "Get-GitHubGitConfig gets the 'system' Git configuration" {
                $gitConfig = Get-GitHubGitConfig -Scope 'system'
                LogGroup 'GitConfig - System' {
                    Write-Host ($gitConfig | Format-List | Out-String)
                }
                $gitConfig | Should -Not -BeNullOrEmpty
            }
            It 'Set-GitHubGitConfig sets the Git configuration' {
                { Set-GitHubGitConfig } | Should -Not -Throw
                $gitConfig = Get-GitHubGitConfig -Scope 'global'
                LogGroup 'GitConfig - Global' {
                    Write-Host ($gitConfig | Format-List | Out-String)
                }
                $gitConfig | Should -Not -BeNullOrEmpty
                $gitConfig.'user.name' | Should -Not -BeNullOrEmpty
                $gitConfig.'user.email' | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe 'Emojis' {
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
        It 'Get-GitHubEmoji - Gets a list of all emojis' {
            $emojis = Get-GitHubEmoji
            LogGroup 'emojis' {
                Write-Host ($emojis | Format-Table | Out-String)
            }
            $emojis | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubEmoji - Downloads all emojis' {
            Get-GitHubEmoji -Path $Home
            LogGroup 'emojis' {
                $emojis = Get-ChildItem -Path $Home -File
                Write-Host ($emojis | Format-Table | Out-String)
            }
            $emojis | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'Webhooks' {
    It 'Test-GitHubWebhookSignature - Validates the webhook payload using known correct signature' {
        $secret = "It's a Secret to Everybody"
        $payload = 'Hello, World!'
        $signature = 'sha256=757107ea0eb2509fc211221cce984b8a37570b6d7586c22c46f4379c8b043e17'
        $result = Test-GitHubWebhookSignature -Secret $secret -Body $payload -Signature $signature
        $result | Should -Be $true
    }
}

Describe 'Anonymous - Functions that can run anonymously' {
    It 'Get-GithubRateLimit - Using -Anonymous' {
        $rateLimit = Get-GitHubRateLimit -Anonymous
        LogGroup 'Rate Limit' {
            Write-Host ($rateLimit | Format-Table | Out-String)
        }
        $rateLimit | Should -Not -BeNullOrEmpty
    }
    It 'Invoke-GitHubAPI - Using -Anonymous' {
        $rateLimit = Invoke-GitHubAPI -ApiEndpoint '/rate_limit' -Anonymous | Select-Object -ExpandProperty Response
        LogGroup 'Rate Limit' {
            Write-Host ($rateLimit | Format-Table | Out-String)
        }
        $rateLimit | Should -Not -BeNullOrEmpty
    }
    It 'Get-GithubRateLimit - Using -Context Anonymous' {
        $rateLimit = Get-GitHubRateLimit -Context Anonymous
        LogGroup 'Rate Limit' {
            Write-Host ($rateLimit | Format-List | Out-String)
        }
        $rateLimit | Should -Not -BeNullOrEmpty
    }
    It 'Invoke-GitHubAPI - Using -Context Anonymous' {
        $rateLimit = Invoke-GitHubAPI -ApiEndpoint '/rate_limit' -Context Anonymous | Select-Object -ExpandProperty Response
        LogGroup 'Rate Limit' {
            Write-Host ($rateLimit | Format-Table | Out-String)
        }
        $rateLimit | Should -Not -BeNullOrEmpty
    }
}
