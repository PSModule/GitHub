[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
)]
[CmdletBinding()]
param()

BeforeAll {
    Get-SecretInfo | Remove-Secret
    Get-SecretVault | Unregister-SecretVault
}

Describe 'GitHub' {
    Context 'Config' {
        It 'Get-GitHubConfig - Can get the configuration' {
            $config = Get-GitHubConfig
            Write-Verbose ($config | Format-Table | Out-String) -Verbose
            $config | Should -Not -BeNullOrEmpty
        }
        It 'Set-GitHubConfig - Can set the configuration' {
            Set-GitHubConfig -Name 'MyName' -Value 'MyValue'
            Get-GitHubConfig -Name 'MyName' | Should -Be 'MyValue'
        }
        It 'Remove-GetGitHubConfig - Can remove the configuration' {
            Remove-GitHubConfig -Name 'MyName'
            { Get-GitHubConfig -Name 'MyName' } | Should -BeNullOrEmpty
        }
        It 'Reset-GitHubConfig - Can reset the configuration' {
            Set-GitHubConfig -Name HostName -Value 'msx.ghe.com'
            Get-GitHubConfig -Name HostName | Should -Be 'msx.ghe.com'
            Reset-GitHubConfig
            Get-GitHubConfig -Name HostName | Should -Be 'github.com'
        }
    }
    Context 'Auth' {
        It 'Can connect and disconnect without parameters in GitHubActions' {
            { Connect-GitHubAccount } | Should -Not -Throw
            { Disconnect-GitHubAccount } | Should -Not -Throw
        }

        It 'Can connect and disconnect - a second time' {
            Connect-GitHubAccount
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
            Write-Verbose (Get-GitHubConfig | Out-String) -Verbose
            Connect-GitHubAccount
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
            Write-Verbose (Get-GitHubConfig | Out-String) -Verbose
            { Disconnect-GitHubAccount } | Should -Not -Throw
        }

        It 'Can pass the context to the pipeline' {
            $context = Connect-GitHubAccount -PassThru
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
            $context | Should -Not -BeNullOrEmpty
            { $context | Disconnect-GitHubAccount } | Should -Not -Throw
        }

        It 'Can connect multiple sessions, GITHUB_TOKEN + classic PAT token' {
            { Connect-GitHubAccount -Token $env:TEST_PAT } | Should -Not -Throw
            { Connect-GitHubAccount -Token $env:TEST_PAT } | Should -Not -Throw
            { Connect-GitHubAccount } | Should -Not -Throw # Logs on with GitHub Actions' token
            (Get-GitHubContext -ListAvailable).Count | Should -Be 2
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/github-actions/Organization/PSModule'
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
        }

        It 'Can reconfigure an existing context to be fine-grained PAT token' {
            { Connect-GitHubAccount -Token $env:TEST_FG_PAT } | Should -Not -Throw
            (Get-GitHubContext -ListAvailable).Count | Should -Be 2
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
        }

        It 'Can be called with a GitHub App' {
            $params = @{
                ClientID   = $env:TEST_APP_CLIENT_ID
                PrivateKey = $env:TEST_APP_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params } | Should -Not -Throw
            $contexts = Get-GitHubContextInfo -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 3
        }

        It 'Can be called with a GitHub App and autoload installations' {
            $params = @{
                ClientID   = $env:TEST_APP_CLIENT_ID
                PrivateKey = $env:TEST_APP_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params -AutoloadInstallations } | Should -Not -Throw
            $contexts = Get-GitHubContextInfo -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 7
        }

        It 'Can disconnect a specific context' {
            { Disconnect-GitHubAccount -Context 'github.com/psmodule-test-app/Organization/PSModule' -Silent } | Should -Not -Throw
            $contexts = Get-GitHubContextInfo -Name 'github.com/psmodule-test-app/*' -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 3
            Connect-GitHubAccount -ClientID $env:TEST_APP_CLIENT_ID -PrivateKey $env:TEST_APP_PRIVATE_KEY -AutoloadInstallations
            $contexts = Get-GitHubContext -ListAvailable -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 7
        }

        It 'Can get the authenticated GitHubApp' {
            $app = Get-GitHubApp
            Write-Verbose ($app | Format-Table | Out-String) -Verbose
            $app | Should -Not -BeNullOrEmpty
        }

        It 'Can connect to a GitHub App Installation' {
            $appContext = Connect-GitHubApp -Organization 'PSModule' -PassThru
            Write-Verbose ($appContext | Out-String) -Verbose
            $appContext | Should -Not -BeNullOrEmpty
            { $appContext | Disconnect-GitHub } | Should -Not -Throw
        }

        It 'Can connect to all GitHub App Installations' {
            { Connect-GitHubApp } | Should -Not -Throw
            Write-Verbose 'Default context:' -Verbose
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
            Write-Verbose 'All contexts:' -Verbose
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
        }

        It 'Can swap context to another' {
            { Set-GitHubDefaultContext -Context 'github.com/github-actions/Organization/PSModule' } | Should -Not -Throw
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/github-actions/Organization/PSModule'
        }

        It 'Get-GitHubViewer can be called' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubConfig gets the DefaultContext' {
            Write-Verbose (Get-GitHubConfig -Name 'DefaultContext') -Verbose
            { Get-GitHubConfig -Name 'DefaultContext' } | Should -Not -Throw
        }
        It 'Can be called without a parameter' {
            $config = Get-GitHubConfig
            Write-Verbose ($config | Format-Table | Out-String) -Verbose
            { Get-GitHubConfig } | Should -Not -Throw
            $config.ID | Should -Be 'PSModule.GitHub'
        }
    }
    Context 'Status' -ForEach @('public', 'eu') {
        It 'Can be called with no parameters' {
            { Get-GitHubScheduledMaintenance -Stamp $_ } | Should -Not -Throw
        }
        It 'Can be called with Active parameter' {
            { Get-GitHubScheduledMaintenance -Stamp $_ -Active } | Should -Not -Throw
        }
        It 'Can be called with Upcoming parameter' {
            { Get-GitHubScheduledMaintenance -Stamp $_ -Upcoming } | Should -Not -Throw
        }
        It 'Can be called with no parameters' {
            { Get-GitHubStatus -Stamp $_ } | Should -Not -Throw
        }
        It 'Can be called with Summary parameter' {
            { Get-GitHubStatus -Stamp $_ -Summary } | Should -Not -Throw
        }
        It 'Can be called with no parameters' {
            { Get-GitHubStatusComponent -Stamp $_ } | Should -Not -Throw
        }
        It 'Can be called with no parameters' {
            { Get-GitHubStatusIncident -Stamp $_ } | Should -Not -Throw
        }
        It 'Can be called with Unresolved parameter' {
            { Get-GitHubStatusIncident -Stamp $_ -Unresolved } | Should -Not -Throw
        }
    }
    Context 'Commands' {
        It "Start-GitHubLogGroup 'MyGroup' should not throw" {
            {
                Start-GitHubLogGroup 'MyGroup'
            } | Should -Not -Throw
        }
        It 'Stop-LogGroup should not throw' {
            {
                Stop-GitHubLogGroup
            } | Should -Not -Throw
        }
        It "Set-GitHubLogGroup 'MyGroup' should not throw" {
            {
                Set-GitHubLogGroup -Name 'MyGroup' -ScriptBlock {
                    Get-ChildItem env: | Select-Object Name, Value | Format-Table -AutoSize
                }
            } | Should -Not -Throw
        }
        It "LogGroup 'MyGroup' should not throw" {
            {
                LogGroup 'MyGroup' {
                    Get-ChildItem env: | Select-Object Name, Value | Format-Table -AutoSize
                }
            } | Should -Not -Throw
        }
        It 'Add-GitHubMask should not throw' {
            {
                Add-GitHubMask -Value 'taskmaster'
            } | Should -Not -Throw
        }
        It 'Add-GitHubSystemPath should not throw' {
            {
                Add-GitHubSystemPath -Path $pwd.ToString()
            } | Should -Not -Throw
            $env:Path | Should -Contain $pwd.ToString()
        }
        It 'Disable-GitHubCommand should not throw' {
            {
                Disable-GitHubCommand -String 'MyString'
            } | Should -Not -Throw
        }
        It 'Enable-GitHubCommand should not throw' {
            {
                Enable-GitHubCommand -String 'MyString'
            } | Should -Not -Throw
        }
        It 'Set-GitHubNoCommandGroup should not throw' {
            {
                Set-GitHubNoCommandGroup {
                    Write-Output 'Hello, World!'
                }
            } | Should -Not -Throw
        }
        It 'Set-GitHubOutput should not throw' {
            {
                Set-GitHubOutput -Name 'MyName' -Value 'MyValue'
            } | Should -Not -Throw
        }
        It 'Get-GitHubOutput should not throw' {
            {
                Get-GitHubOutput
            } | Should -Not -Throw
        }
        It 'Set-GitHubEnvironmentVariable should not throw' {
            {
                Set-GitHubEnvironmentVariable -Name 'MyName' -Value 'MyValue'
            } | Should -Not -Throw
            $env:MyName | Should -Be 'MyValue'
        }
        It 'Set-GitHubStepSummary should not throw' {
            {
                Set-GitHubStepSummary -Summary 'MySummary'
            } | Should -Not -Throw
        }
        It 'Write-GitHub* should not throw' {
            { Write-GitHubDebug 'Debug' } | Should -Not -Throw
            { Write-GitHubError 'Error' } | Should -Not -Throw
            { Write-GitHubNotice 'Notice' } | Should -Not -Throw
            { Write-GitHubWarning 'Warning' } | Should -Not -Throw
        }
    }
    Context 'Disconnect' {
        It 'Can disconnect without parameters' {
            { Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount } | Should -Not -Throw
            Get-GitHubContext -ListAvailable | Should -HaveCount 0
        }
    }
}

Describe 'As a user - Fine-grained PAT token' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_FG_PAT
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'API' {
        It 'Can be called directly to get ratelimits' {
            {
                $rateLimit = Invoke-GitHubAPI -ApiEndpoint '/rate_limit'
                Write-Verbose ($rateLimit | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw

        }
    }
    Context 'GraphQL' {
        It 'Can be called directly to get viewer' {
            {
                $viewer = Invoke-GitHubGraphQLQuery -Query 'query { viewer { login } }'
                Write-Verbose ($viewer | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
    Context 'Meta' {
        It 'Get-GitHubRoot' {
            $root = Get-GitHubRoot
            Write-Verbose ($root | Format-Table | Out-String) -Verbose
            $root | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubApiVersion' {
            $apiVersion = Get-GitHubApiVersion
            Write-Verbose ($apiVersion | Format-Table | Out-String) -Verbose
            $apiVersion | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubMeta' {
            $meta = Get-GitHubMeta
            Write-Verbose ($meta | Format-Table | Out-String) -Verbose
            $meta | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubOctocat' {
            $octocat = Get-GitHubOctocat
            Write-Verbose ($octocat | Format-Table | Out-String) -Verbose
            $octocat | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubZen' {
            $zen = Get-GitHubZen
            Write-Verbose ($zen | Format-Table | Out-String) -Verbose
            $zen | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Rate-Limit' {
        It 'Can be called with no parameters' {
            { Get-GitHubRateLimit } | Should -Not -Throw
        }
    }
    Context 'License' {
        It 'Can be called with no parameters' {
            { Get-GitHubLicense } | Should -Not -Throw
        }
        It 'Can be called with Name parameter' {
            { Get-GitHubLicense -Name 'mit' } | Should -Not -Throw
        }
        It 'Can be called with Repository parameter' {
            { Get-GitHubLicense -Owner 'PSModule' -Repo 'GitHub' } | Should -Not -Throw
        }
    }
    Context 'Emoji' {
        It 'Can be called with no parameters' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Can be download the emojis' {
            { Get-GitHubEmoji -Destination $env:TEMP } | Should -Not -Throw
        }
    }
    Context 'Repository' {
        Context 'Parameter Set: MyRepos_Type' {
            It 'Can be called with no parameters' {
                { Get-GitHubRepository - } | Should -Not -Throw
            }

            It 'Can be called with Type parameter' {
                { Get-GitHubRepository -Type 'public' } | Should -Not -Throw
            }
        }
        Context 'Parameter Set: MyRepos_Aff-Vis' {
            It 'Can be called with Visibility and Affiliation parameters' {
                { Get-GitHubRepository -Visibility 'public' -Affiliation 'owner' } | Should -Not -Throw
            }
        }
        It 'Can be called with Owner and Repo parameters' {
            { Get-GitHubRepository -Owner 'PSModule' -Repo 'GitHub' } | Should -Not -Throw
        }
        It 'Can be called with Owner parameter' {
            { Get-GitHubRepository -Owner 'PSModule' } | Should -Not -Throw
        }
        It 'Can be called with Username parameter' {
            { Get-GitHubRepository -Username 'MariusStorhaug' } | Should -Not -Throw
        }
    }
    Context 'GitIgnore' {
        It 'Can be called with no parameters' {
            { Get-GitHubGitignore } | Should -Not -Throw
        }
        It 'Can be called with Name parameter' {
            { Get-GitHubGitignore -Name 'VisualStudio' } | Should -Not -Throw
        }
    }
}

Describe 'As a user - Classic PAT token' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_PAT
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'API' {
        It 'Can be called directly to get ratelimits' {
            {
                $rateLimit = Invoke-GitHubAPI -ApiEndpoint '/rate_limit'
                Write-Verbose ($rateLimit | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw

        }
    }
    Context 'GraphQL' {
        It 'Can be called directly to get viewer' {
            {
                $viewer = Invoke-GitHubGraphQLQuery -Query 'query { viewer { login } }'
                Write-Verbose ($viewer | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
    Context 'Meta' {
        It 'Get-GitHubRoot' {
            $root = Get-GitHubRoot
            Write-Verbose ($root | Format-Table | Out-String) -Verbose
            $root | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubApiVersion' {
            $apiVersion = Get-GitHubApiVersion
            Write-Verbose ($apiVersion | Format-Table | Out-String) -Verbose
            $apiVersion | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubMeta' {
            $meta = Get-GitHubMeta
            Write-Verbose ($meta | Format-Table | Out-String) -Verbose
            $meta | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubOctocat' {
            $octocat = Get-GitHubOctocat
            Write-Verbose ($octocat | Format-Table | Out-String) -Verbose
            $octocat | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubZen' {
            $zen = Get-GitHubZen
            Write-Verbose ($zen | Format-Table | Out-String) -Verbose
            $zen | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Rate-Limit' {
        It 'Can be called with no parameters' {
            { Get-GitHubRateLimit } | Should -Not -Throw
        }
    }
    Context 'License' {
        It 'Can be called with no parameters' {
            { Get-GitHubLicense } | Should -Not -Throw
        }
        It 'Can be called with Name parameter' {
            { Get-GitHubLicense -Name 'mit' } | Should -Not -Throw
        }
        It 'Can be called with Repository parameter' {
            { Get-GitHubLicense -Owner 'PSModule' -Repo 'GitHub' } | Should -Not -Throw
        }
    }
    Context 'Emoji' {
        It 'Can be called with no parameters' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Can be download the emojis' {
            { Get-GitHubEmoji -Destination $env:TEMP } | Should -Not -Throw
        }
    }
    Context 'GitIgnore' {
        It 'Can be called with no parameters' {
            { Get-GitHubGitignore } | Should -Not -Throw
        }
        It 'Can be called with Name parameter' {
            { Get-GitHubGitignore -Name 'VisualStudio' } | Should -Not -Throw
        }
    }
}

Describe 'As GitHub Actions' {
    BeforeAll {
        Connect-GitHubAccount
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'API' {
        It 'Can be called directly to get ratelimits' {
            {
                $rateLimit = Invoke-GitHubAPI -ApiEndpoint '/rate_limit'
                Write-Verbose ($rateLimit | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw

        }
    }
    Context 'GraphQL' {
        It 'Can be called directly to get viewer' {
            {
                $viewer = Invoke-GitHubGraphQLQuery -Query 'query { viewer { login } }'
                Write-Verbose ($viewer | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
    Context 'Git' {
        It 'Set-GitHubGitConfig sets the Git configuration' {
            { Set-GitHubGitConfig } | Should -Not -Throw
            $gitConfig = Get-GitHubGitConfig
            Write-Verbose ($gitConfig | Format-Table | Out-String) -Verbose

            $gitConfig | Should -Not -BeNullOrEmpty
            $gitConfig.'user.name' | Should -Not -BeNullOrEmpty
            $gitConfig.'user.email' | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Meta' {
        It 'Get-GitHubRoot' {
            $root = Get-GitHubRoot
            Write-Verbose ($root | Format-Table | Out-String) -Verbose
            $root | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubApiVersion' {
            $apiVersion = Get-GitHubApiVersion
            Write-Verbose ($apiVersion | Format-Table | Out-String) -Verbose
            $apiVersion | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubMeta' {
            $meta = Get-GitHubMeta
            Write-Verbose ($meta | Format-Table | Out-String) -Verbose
            $meta | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubOctocat' {
            $octocat = Get-GitHubOctocat
            Write-Verbose ($octocat | Format-Table | Out-String) -Verbose
            $octocat | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubZen' {
            $zen = Get-GitHubZen
            Write-Verbose ($zen | Format-Table | Out-String) -Verbose
            $zen | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Rate-Limit' {
        It 'Can be called with no parameters' {
            { Get-GitHubRateLimit } | Should -Not -Throw
        }
    }
    Context 'License' {
        It 'Can be called with no parameters' {
            { Get-GitHubLicense } | Should -Not -Throw
        }
        It 'Can be called with Name parameter' {
            { Get-GitHubLicense -Name 'mit' } | Should -Not -Throw
        }
        It 'Can be called with Repository parameter' {
            { Get-GitHubLicense -Owner 'PSModule' -Repo 'GitHub' } | Should -Not -Throw
        }
    }
    Context 'Emoji' {
        It 'Can be called with no parameters' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Can be download the emojis' {
            { Get-GitHubEmoji -Destination $env:TEMP } | Should -Not -Throw
        }
    }
    Context 'GitIgnore' {
        It 'Can be called with no parameters' {
            { Get-GitHubGitignore } | Should -Not -Throw
        }
        It 'Can be called with Name parameter' {
            { Get-GitHubGitignore -Name 'VisualStudio' } | Should -Not -Throw
        }
    }
}

Describe 'As a GitHub App' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_CLIENT_ID -PrivateKey $env:TEST_APP_PRIVATE_KEY
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'App' {
        It 'Can get a JWT for the app' {
            $jwt = Get-GitHubAppJSONWebToken -ClientId $env:TEST_APP_CLIENT_ID -PrivateKey $env:TEST_APP_PRIVATE_KEY
            Write-Verbose ($jwt | Format-Table | Out-String) -Verbose
            $jwt | Should -Not -BeNullOrEmpty
        }
        It 'Can get app details' {
            $app = Get-GitHubApp
            Write-Verbose ($app | Format-Table | Out-String) -Verbose
            $app | Should -Not -BeNullOrEmpty
        }
    }
    Context 'API' {
        It 'Can be called directly to get ratelimits' {
            {
                $app = Invoke-GitHubAPI -ApiEndpoint '/app'
                Write-Verbose ($app | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
}
