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
            LogGroup 'Context - Standard' {
                Write-Host ($context | Out-String)
            }
            LogGroup 'Context - Format-List' {
                Write-Host ($context | Format-List | Out-String)
            }
            LogGroup 'Context - Format-Table' {
                Write-Host ($context | Format-Table | Out-String)
            }
            LogGroup 'Context - Full' {
                Write-Host ($context | Select-Object * | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
        }

        It 'Connect-GitHubAccount - TokenExpiresIn should be null for PAT tokens' -Skip:($AuthType -ne 'PAT') {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            $context.TokenExpiresAt | Should -BeNullOrEmpty
            $context.TokenExpiresIn | Should -BeNullOrEmpty
        }

        It 'Connect-GitHubAccount - TokenExpiresIn should be null for GITHUB_TOKEN (IAT)' -Skip:($TokenType -ne 'GITHUB_TOKEN') {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            $context.TokenExpiresAt | Should -BeNullOrEmpty
            $context.TokenExpiresIn | Should -BeNullOrEmpty
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
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent -AutoloadInstallations
            LogGroup 'Connect-Github' {
                Write-Host ($context | Out-String)
            }
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
            $context | Should -BeOfType [GitHubContext]
            $context.TokenExpiresAt | Should -BeOfType [DateTime]
            $context.TokenExpiresIn | Should -BeOfType [TimeSpan]
        }

        It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' -Skip:($AuthType -ne 'APP') {
            $contexts = Connect-GitHubApp -PassThru -Silent
            LogGroup 'Connect-GithubApp' {
                Write-Host ($contexts | Out-String)
            }
            LogGroup 'Context - Standard' {
                Write-Host ($contexts | Out-String)
            }
            LogGroup 'Context - Format-List' {
                Write-Host ($contexts | Format-List | Out-String)
            }
            LogGroup 'Context - Format-Table' {
                Write-Host ($contexts | Format-Table | Out-String)
            }
            LogGroup 'Context - Full' {
                Write-Host ($contexts | Select-Object * | Out-String)
            }
            $contexts | Should -Not -BeNullOrEmpty
        }

        It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' -Skip:($AuthType -ne 'APP') {
            $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
            LogGroup 'Connect-GithubApp' {
                $context
            }
            $context.TokenExpiresAt | Should -BeOfType [DateTime]
            $context.TokenExpiresIn | Should -BeOfType [TimeSpan]
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
        }

        It 'Connect-GitHubApp - Installation tokens (IAT) should have expiration set' -Skip:($AuthType -ne 'APP') {
            $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
            $context.AuthType | Should -Be 'IAT'
            $context.TokenExpiresAt | Should -BeOfType [DateTime]
            $context.TokenExpiresIn | Should -BeOfType [TimeSpan]
            $context.TokenExpiresIn.TotalMinutes | Should -BeGreaterThan 0
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
                Write-Host ($context | Format-List | Out-String)
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

        It 'Get-GitHubAccessToken - Gets token as SecureString by default' {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            $token = Get-GitHubAccessToken
            $token | Should -BeOfType [System.Security.SecureString]
        }

        It 'Get-GitHubAccessToken - Gets token as plain text with -AsPlainText' {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            $token = Get-GitHubAccessToken -AsPlainText
            $token | Should -BeOfType [System.String]
            $token | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubAccessToken - Works with explicit -Context parameter' {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            $token = Get-GitHubAccessToken -Context $context -AsPlainText
            $token | Should -BeOfType [System.String]
            $token | Should -Not -BeNullOrEmpty

            $secureToken = Get-GitHubAccessToken -Context $context
            $secureToken | Should -BeOfType [System.Security.SecureString]
        }
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

Describe 'GitHub' {
    Context 'Config' {
        It 'Get-GitHubConfig - Gets the module configuration' {
            LogGroup 'Config' {
                $config = Get-GitHubConfig
                Write-Host ($config | Format-List | Out-String)
            }
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
            LogGroup 'Event Data' {
                $eventData = Get-GitHubEventData
                Write-Host ($eventData | Format-List | Out-String)
            }
            $eventData | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRunnerData - Gets data about the runner that is running the workflow' {
            LogGroup 'Runner Data' {
                $runnerData = Get-GitHubRunnerData
                Write-Host ($runnerData | Format-List | Out-String)
            }
            $runnerData | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Status' -ForEach @('Public', 'Europe', 'Australia', 'US') {
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
        It 'Set-GitHubOutput + Empty string - Should not throw' {
            {
                Set-GitHubOutput -Name 'EmptyOutput' -Value ''
            } | Should -Not -Throw
            (Get-GitHubOutput).EmptyOutput | Should -Be ''
        }
        It 'Set-GitHubOutput + Null - Should not throw and store as null' {
            {
                Set-GitHubOutput -Name 'NullOutput' -Value $null
            } | Should -Not -Throw
            $nullValue = (Get-GitHubOutput).NullOutput
            $nullValue | Should -Be $null

            # Check the actual file content format
            $content = Get-Content -Path $env:GITHUB_OUTPUT -Raw
            $content | Should -Match 'NullOutput<<EOF_[a-z0-9-]+\r?\nEOF_[a-z0-9-]+'
        }

        It 'Set-GitHubOutput + Empty String - Should store as empty string' {
            {
                Set-GitHubOutput -Name 'EmptyStringOutput' -Value ''
            } | Should -Not -Throw
            (Get-GitHubOutput).EmptyStringOutput | Should -Be ''

            # Check the actual file content format
            $content = Get-Content -Path $env:GITHUB_OUTPUT -Raw
            $content | Should -Match 'EmptyStringOutput<<EOF_[a-z0-9-]+\r?\n\r?\nEOF_[a-z0-9-]+'
        }

        It 'Set-GitHubOutput - Should work with existing multi-line outputs in file' {
            $existingContent = @'
stderr<<ghadelimiter_6f9f5610-74ad-4b25-8ef3-7f3e9e764fa2
ghadelimiter_6f9f5610-74ad-4b25-8ef3-7f3e9e764fa2
'@
            Add-Content -Path $env:GITHUB_OUTPUT -Value $existingContent
            {
                Set-GitHubOutput -Name 'TestAfterExisting' -Value 'TestValue'
            } | Should -Not -Throw
            (Get-GitHubOutput).TestAfterExisting | Should -Be 'TestValue'
            $stderr = (Get-GitHubOutput).stderr
            $stderr | Should -Be $null
        }
        It 'Get-GitHubOutput - Should not throw' {
            {
                Get-GitHubOutput
            } | Should -Not -Throw
            Write-Host (Get-GitHubOutput | Format-List | Out-String)
        }
        It 'Reset-GitHubOutput - Should clear the outputs from the output file' {
            Set-GitHubOutput -Name 'TestOutput' -Value 'TestValue'
            (Get-GitHubOutput).TestOutput | Should -Be 'TestValue'
            Reset-GitHubOutput
            Get-GitHubOutput | Should -BeNullOrEmpty
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
                        Write-Host ($app | Format-List | Out-String)
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
                        Write-Host ($rateLimit | Format-List | Out-String)
                    }
                    LogGroup 'RateLimit - Header' {
                        Write-Host ($rateLimit.Headers | Format-List | Out-String)
                    }
                } | Should -Not -Throw
            }

            It 'Invoke-RestMethod - Gets the rate limits directly using Uri' {
                {
                    $rateLimit = Invoke-RestMethod -Uri ($context.ApiBaseUri + '/rate_limit') -Authentication Bearer -Token (Get-GitHubAccessToken)
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

        Context 'RateLimit' {
            BeforeAll {
                $rateLimits = Get-GitHubRateLimit
            }
            It 'Get-GitHubRateLimit - Gets the rate limit status for the authenticated user' {
                LogGroup 'RateLimit' {
                    Write-Host ($rateLimits | Format-Table | Out-String)
                }
                $rateLimits | Should -Not -BeNullOrEmpty
            }

            It 'Get-GitHubRateLimit - ResetsAt property should be a datetime' {
                $rateLimit = $rateLimits | Select-Object -First 1
                $rateLimit.ResetsAt | Should -BeOfType [DateTime]
                $rateLimit.ResetsAt | Should -BeGreaterThan ([DateTime]::Now)
            }

            It 'Get-GitHubRateLimit - ResetsIn property should be calculated correctly' {
                $rateLimit = $rateLimits | Select-Object -First 1
                $rateLimit.ResetsIn | Should -BeOfType [TimeSpan]
                $rateLimit.ResetsIn.TotalSeconds | Should -BeGreaterThan 0
                $rateLimit.ResetsIn.TotalHours | Should -BeLessOrEqual 1
            }

            It 'Get-GitHubRateLimit - Should return objects with names core and rate' {
                LogGroup 'RateLimit Names' {
                    Write-Host ($rateLimits.Name | Out-String)
                }
                $rateLimits.Name | Should -Contain 'core'
                $rateLimits.Name | Should -Contain 'rate'
            }

            It 'Get-GitHubRateLimit - Objects should be of type GitHubRateLimitResource' {
                $rateLimits | Should -BeOfType 'GitHubRateLimitResource'
            }

            It 'Get-GitHubRateLimit - Should have correct property types for all objects' {
                $rateLimits.Name | Should -BeOfType [String]
                $rateLimits.Limit | Should -BeOfType [UInt64]
                $rateLimits.Used | Should -BeOfType [UInt64]
                $rateLimits.Remaining | Should -BeOfType [UInt64]
                $rateLimits.ResetsAt | Should -BeOfType [DateTime]
                $rateLimits.ResetsIn | Should -BeOfType [TimeSpan]
                $rateLimits.Name | Should -Not -BeNullOrEmpty
                $rateLimits.Limit | Should -BeGreaterOrEqual 0
                $rateLimits.Used | Should -BeGreaterOrEqual 0
                $rateLimits.Remaining | Should -BeGreaterOrEqual 0
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

Describe 'Webhooks' {
    BeforeAll {
        $secret = "It's a Secret to Everybody"
        $payload = 'Hello, World!'
        $signature = 'sha256=757107ea0eb2509fc211221cce984b8a37570b6d7586c22c46f4379c8b043e17'
    }

    It 'Test-GitHubWebhookSignature - Validates the webhook payload using known correct signature (SHA256)' {
        $result = Test-GitHubWebhookSignature -Secret $secret -Body $payload -Signature $signature
        $result | Should -Be $true
    }

    It 'Test-GitHubWebhookSignature - Validates the webhook using Request object' {
        $mockRequest = [PSCustomObject]@{
            RawBody = $payload
            Headers = @{
                'X-Hub-Signature-256' = $signature
            }
        }
        $result = Test-GitHubWebhookSignature -Secret $secret -Request $mockRequest
        $result | Should -Be $true
    }

    It 'Test-GitHubWebhookSignature - Should fail with invalid signature' {
        $invalidSignature = 'sha256=invalid'
        $result = Test-GitHubWebhookSignature -Secret $secret -Body $payload -Signature $invalidSignature
        $result | Should -Be $false
    }

    It 'Test-GitHubWebhookSignature - Should throw when signature header is missing from request' {
        $mockRequest = [PSCustomObject]@{
            RawBody = $payload
            Headers = @{}
        }

        { Test-GitHubWebhookSignature -Secret $secret -Request $mockRequest } | Should -Throw
    }
}
