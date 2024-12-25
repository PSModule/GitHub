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
        It 'Get-GitHubConfig - Gets the module configuration' {
            $config = Get-GitHubConfig
            Write-Verbose ($config | Format-Table | Out-String) -Verbose
            $config | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubConfig - Gets a configuration item by name' {
            $config = Get-GitHubConfig -Name 'HostName'
            Write-Verbose ($config | Format-Table | Out-String) -Verbose
            $config | Should -Not -BeNullOrEmpty
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
    Context 'Auth' {
        It 'Connect-GitHubAccount - Connects GitHub Actions without parameters' {
            { Connect-GitHubAccount } | Should -Not -Throw
        }
        It 'Disconnect-GitHubAccount - Disconnects GitHub Actions' {
            { Disconnect-GitHubAccount } | Should -Not -Throw
        }
        It 'Connect-GitHubAccount - Passes the context to the pipeline' {
            $context = Connect-GitHubAccount -PassThru
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
            $context | Should -Not -BeNullOrEmpty
        }
        It 'Disconnect-GitHubAccount - Disconnects the context from the pipeline' {
            { $context | Disconnect-GitHubAccount } | Should -Not -Throw
        }
        It 'Connect-GitHubAccount - Connects GitHub Actions even if called multiple times' {
            { Connect-GitHubAccount } | Should -Not -Throw
            { Connect-GitHubAccount } | Should -Not -Throw
        }
        It 'Connect-GitHubAccount - Connects multiple contexts, GitHub Actions and a user via classic PAT token' {
            { Connect-GitHubAccount } | Should -Not -Throw
            { Connect-GitHubAccount -Token $env:TEST_USER_PAT } | Should -Not -Throw
            { Connect-GitHubAccount -Token $env:TEST_USER_PAT } | Should -Not -Throw
            (Get-GitHubContext -ListAvailable).Count | Should -Be 2
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/github-actions/Organization/PSModule'
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
        }
        It 'Connect-GitHubAccount - Reconfigures an existing user context to be a fine-grained PAT token' {
            { Connect-GitHubAccount -Token $env:TEST_USER_USER_FG_PAT } | Should -Not -Throw
            (Get-GitHubContext -ListAvailable).Count | Should -Be 2
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
        }
        It 'Connect-GitHubAccount - Connects a GitHub App from an organization' {
            $params = @{
                ClientID   = $env:TEST_APP_ORG_CLIENT_ID
                PrivateKey = $env:TEST_APP_ORG_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params } | Should -Not -Throw
            $contexts = Get-GitHubContextInfo -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 3
        }
        It 'Connect-GitHubAccount - Connects all of a (org) GitHub Apps installations' {
            $params = @{
                ClientID   = $env:TEST_APP_ORG_CLIENT_ID
                PrivateKey = $env:TEST_APP_ORG_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params -AutoloadInstallations } | Should -Not -Throw
            $contexts = Get-GitHubContextInfo -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 5
        }
        It 'Connect-GitHubAccount - Connects a GitHub App from an enterprise' {
            $params = @{
                ClientID   = $env:TEST_APP_ENT_CLIENT_ID
                PrivateKey = $env:TEST_APP_ENT_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params } | Should -Not -Throw
            $contexts = Get-GitHubContextInfo -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 6
        }
        It 'Connect-GitHubAccount - Connects all of a (ent) GitHub Apps installations' {
            $params = @{
                ClientID   = $env:TEST_APP_ENT_CLIENT_ID
                PrivateKey = $env:TEST_APP_ENT_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params -AutoloadInstallations } | Should -Not -Throw
            $contexts = Get-GitHubContextInfo -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 9
        }
        It 'Disconnect-GitHubAccount - Disconnects a specific context' {
            { Disconnect-GitHubAccount -Context 'github.com/psmodule-enterprise-app/Organization/PSModule' -Silent } | Should -Not -Throw
            $contexts = Get-GitHubContextInfo -Name 'github.com/psmodule-enterprise-app/*' -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 2
        }
        It 'Set-GitHubDefaultContext - Can swap context to another' {
            { Set-GitHubDefaultContext -Context 'github.com/github-actions/Organization/PSModule' } | Should -Not -Throw
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/github-actions/Organization/PSModule'
        }
    }
    Context 'Status' -ForEach @('public', 'eu') {
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
        It 'Set-GitHubOutput - Should not throw' {
            {
                Set-GitHubOutput -Name 'MyName' -Value 'MyValue'
            } | Should -Not -Throw
        }
        It 'Get-GitHubOutput - Should not throw' {
            {
                Get-GitHubOutput
            } | Should -Not -Throw
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
        }
    }
    Context 'Disconnect' {
        It 'Disconnect-GitHubAccount - Can disconnect all context through the pipeline' {
            { Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount } | Should -Not -Throw
            Get-GitHubContext -ListAvailable | Should -HaveCount 0
        }
    }
}

Describe 'As a user - Fine-grained PAT token - user account access' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_USER_FG_PAT
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Auth' {
        It 'Get-GitHubViewer - Gets the logged in context' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
    }
    Context 'API' {
        It 'Invoke-GitHubAPI - Gets the rate limits directly' {
            {
                $rateLimit = Invoke-GitHubAPI -ApiEndpoint '/rate_limit'
                Write-Verbose ($rateLimit | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
    Context 'GraphQL' {
        It 'Invoke-GitHubGraphQLQuery - Gets the viewer directly' {
            {
                $viewer = Invoke-GitHubGraphQLQuery -Query 'query { viewer { login } }'
                Write-Verbose ($viewer | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
    Context 'Meta' {
        It 'Get-GitHubRoot - Gets the GitHub API Root' {
            $root = Get-GitHubRoot
            Write-Verbose ($root | Format-Table | Out-String) -Verbose
            $root | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubApiVersion - Gets all API versions' {
            $apiVersion = Get-GitHubApiVersion
            Write-Verbose ($apiVersion | Format-Table | Out-String) -Verbose
            $apiVersion | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubMeta - Gets GitHub meta information' {
            $meta = Get-GitHubMeta
            Write-Verbose ($meta | Format-Table | Out-String) -Verbose
            $meta | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubOctocat - Gets the Octocat' {
            $octocat = Get-GitHubOctocat
            Write-Verbose ($octocat | Format-Table | Out-String) -Verbose
            $octocat | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubZen - Gets the Zen of GitHub' {
            $zen = Get-GitHubZen
            Write-Verbose ($zen | Format-Table | Out-String) -Verbose
            $zen | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Rate-Limit' {
        It 'Get-GitHubRateLimit - Gets the rate limit status for the authenticated user' {
            { Get-GitHubRateLimit } | Should -Not -Throw
        }
    }
    Context 'License' {
        It 'Get-GitHubLicense - Gets a list of all popular license templates' {
            { Get-GitHubLicense } | Should -Not -Throw
        }
        It 'Get-GitHubLicense - Gets a spesific license' {
            { Get-GitHubLicense -Name 'mit' } | Should -Not -Throw
        }
        It 'Get-GitHubLicense - Gets a license from a repository' {
            { Get-GitHubLicense -Owner 'PSModule' -Repo 'GitHub' } | Should -Not -Throw
        }
    }
    Context 'Emoji' {
        It 'Get-GitHubEmoji - Gets a list of all emojis' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis' {
            { Get-GitHubEmoji -Destination $Home } | Should -Not -Throw
        }
    }
    Context 'Repository' {
        It "Get-GitHubRepository - Gets the authenticated user's repositories" {
            { Get-GitHubRepository } | Should -Not -Throw
        }
        It "Get-GitHubRepository - Gets the authenticated user's public repositories" {
            { Get-GitHubRepository -Type 'public' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets the public repos where the authenticated user is owner' {
            { Get-GitHubRepository -Visibility 'public' -Affiliation 'owner' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets a specific repository' {
            { Get-GitHubRepository -Owner 'PSModule' -Repo 'GitHub' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets all repositories from a organization' {
            { Get-GitHubRepository -Owner 'PSModule' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets all repositories from a user' {
            { Get-GitHubRepository -Username 'MariusStorhaug' } | Should -Not -Throw
        }
    }
    Context 'GitIgnore' {
        It 'Get-GitHubGitignore - Gets a list of all gitignore templates names' {
            { Get-GitHubGitignore } | Should -Not -Throw
        }
        It 'Get-GitHubGitignore - Gets a gitignore template' {
            { Get-GitHubGitignore -Name 'VisualStudio' } | Should -Not -Throw
        }
    }
    Context 'Markdown' {
        It 'Get-GitHubMarkdown - Gets the rendered markdown for provided text' {
            { Get-GitHubMarkdown -Text 'Hello, World!' } | Should -Not -Throw
        }
        It 'Get-GitHubMarkdown - Gets the rendered markdown for provided text using GitHub Formated Markdown' {
            { Get-GitHubMarkdown -Text 'Hello, World!' -Mode gfm } | Should -Not -Throw
        }
        It 'Get-GitHubMarkdownRaw - Gets the raw rendered markdown for provided text' {
            { Get-GitHubMarkdownRaw -Text 'Hello, World!' } | Should -Not -Throw
        }
    }
    Context 'User' {
        It 'Get-GitHubUser - Gets the authenticated user' {
            { Get-GitHubUser } | Should -Not -Throw
        }
        It 'Get-GitHubUser - Get the specified user' {
            { Get-GitHubUser -Username 'Octocat' } | Should -Not -Throw
        }
        It 'Get-GitHubUser - Can set configuration on a user' {
            $user = Get-GitHubUser
            $params = @{
                Name            = 'Octocat'
                Email           = 'psmodule@psmodule.io'
                Blog            = 'https://marius-storhaug.com'
                TwitterUsername = 'MariusStorhaug123'
                Company         = 'PSModule'
                Location        = 'USA'
                Hireable        = $true
                Bio             = 'I love programming'
            }
            { Set-GitHubUser @params } | Should -Not -Throw
            $tmpUser = Get-GitHubUser
            $tmpUser.Name | Should -Be 'Octocat'
            $tmpUser.Email | Should -Be 'psmodule@psmodule.io'
            $tmpUser.Blog | Should -Be 'https://marius-storhaug.com'
            $tmpUser.TwitterUsername | Should -Be 'MariusStorhaug123'
            $tmpUser.Company | Should -Be 'PSModule'
            $tmpUser.Location | Should -Be 'USA'
            $tmpUser.Hireable | Should -Be $true
            $tmpUser.Bio | Should -Be 'I love programming'
            $user = @{
                Name            = $user.Name
                Email           = $user.Email
                Blog            = $user.Blog
                TwitterUsername = $user.TwitterUsername
                Company         = $user.Company
                Location        = $user.Location
                Hireable        = $user.Hireable
                Bio             = $user.Bio
            }
            Set-GitHubUser @user
        }
    }
}

Describe 'As a user - Fine-grained PAT token - organization account access' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_ORG_FG_PAT
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Auth' {
        It 'Get-GitHubViewer - Gets the logged in context' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
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
            { Get-GitHubEmoji -Destination $Home } | Should -Not -Throw
        }
    }
    Context 'Repository' {
        Context 'Parameter Set: MyRepos_Type' {
            It 'Can be called with no parameters' {
                { Get-GitHubRepository } | Should -Not -Throw
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
    Context 'Markdown' {
        It 'Can be called with Text parameter' {
            { Get-GitHubMarkdown -Text 'Hello, **World**' } | Should -Not -Throw
        }
        It 'Can be called with Text parameter and GitHub Format Mardown' {
            { Get-GitHubMarkdown -Text 'Hello, **World**' -Mode gfm } | Should -Not -Throw
        }
        It 'Raw - Can be called with Text parameter' {
            { Get-GitHubMarkdownRaw -Text 'Hello, **World**' } | Should -Not -Throw
        }
    }
    Context 'User' {
        It 'Can be called with no parameters' {
            { Get-GitHubUser } | Should -Not -Throw
        }
        It 'Can be called with Username parameter' {
            { Get-GitHubUser -Username 'Octocat' } | Should -Not -Throw
        }
    }
}

Describe 'As a user - Classic PAT token' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_PAT
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Auth' {
        It 'Get-GitHubViewer - Gets the logged in context' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
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
            { Get-GitHubEmoji -Destination $Home } | Should -Not -Throw
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
    Context 'Markdown' {
        It 'Can be called with Text parameter' {
            { Get-GitHubMarkdown -Text 'Hello, World!' } | Should -Not -Throw
        }
        It 'Can be called with Text parameter and GitHub Format Mardown' {
            { Get-GitHubMarkdown -Text 'Hello, World!' -Mode gfm } | Should -Not -Throw
        }
        It 'Raw - Can be called with Text parameter' {
            { Get-GitHubMarkdownRaw -Text 'Hello, World!' } | Should -Not -Throw
        }
    }
    Context 'User' {
        It 'Can be called with no parameters' {
            { Get-GitHubUser } | Should -Not -Throw
        }
        It 'Can be called with Username parameter' {
            { Get-GitHubUser -Username 'Octocat' } | Should -Not -Throw
        }
        It 'Can be called with no parameters' {
            $repo = Get-GitHubRepository -Owner 'PSModule' -Repo 'GitHub'
            { Get-GitHubUserCard -Username 'MariusStorhaug' -SubjectType repository -SubjectID $repo.id } | Should -Not -Throw
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
    Context 'Auth' {
        It 'Get-GitHubViewer - Gets the logged in context' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
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
            { Get-GitHubEmoji -Destination $Home } | Should -Not -Throw
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
    Context 'Markdown' {
        It 'Can be called with Text parameter' {
            { Get-GitHubMarkdown -Text 'Hello, World!' } | Should -Not -Throw
        }
        It 'Can be called with Text parameter and GitHub Format Mardown' {
            { Get-GitHubMarkdown -Text 'Hello, World!' -Mode gfm } | Should -Not -Throw
        }
        It 'Raw - Can be called with Text parameter' {
            { Get-GitHubMarkdownRaw -Text 'Hello, World!' } | Should -Not -Throw
        }
    }
    Context 'User' {
        It 'Can be called with Username parameter' {
            { Get-GitHubUser -Username 'Octocat' } | Should -Not -Throw
        }
    }
}

Describe 'As a GitHub App - Enterprise' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ENT_CLIENT_ID -PrivateKey $env:TEST_APP_ENT_PRIVATE_KEY
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'User' {
        It 'Can be called with Username parameter' {
            { Get-GitHubUser -Username 'Octocat' } | Should -Not -Throw
        }
    }
    Context 'App' {
        It 'Can get the authenticated GitHubApp' {
            $app = Get-GitHubApp
            Write-Verbose ($app | Format-Table | Out-String) -Verbose
            $app | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'As a GitHub App - Organization' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Apps' {
        Context 'GitHub Apps' {
            It 'Can get a JWT for the app' {
                $jwt = Get-GitHubAppJSONWebToken -ClientId $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
                Write-Verbose ($jwt | Format-Table | Out-String) -Verbose
                $jwt | Should -Not -BeNullOrEmpty
            }
            It 'Can get app details' {
                $app = Get-GitHubApp
                Write-Verbose ($app | Format-Table | Out-String) -Verbose
                $app | Should -Not -BeNullOrEmpty
            }
            It 'Can get app installations' {
                $installations = Get-GitHubAppInstallation
                Write-Verbose ($installations | Format-Table | Out-String) -Verbose
                $installations | Should -Not -BeNullOrEmpty
            }
            It 'Can get app installation access tokens' {
                $installations = Get-GitHubAppInstallation
                $installations | ForEach-Object {
                    $token = New-GitHubAppInstallationAccessToken -InstallationID $_.id
                    Write-Verbose ($token | Format-Table | Out-String) -Verbose
                    $token | Should -Not -BeNullOrEmpty
                }
            }
        }
        Context 'Webhooks' {
            It 'Can get the webhook configuration' {
                $webhooks = Get-GitHubAppWebhookConfiguration
                Write-Verbose ($webhooks | Format-Table | Out-String) -Verbose
                $webhooks | Should -Not -BeNullOrEmpty
            }
            It 'Can update the webhook configuration' {
                { Update-GitHubAppWebhookConfiguration -ContentType 'form' } | Should -Not -Throw
                { Update-GitHubAppWebhookConfiguration -ContentType 'json' } | Should -Not -Throw
            }
            It 'Can get webhook deliveries' {
                $deliveries = Get-GitHubAppWebhookDelivery
                Write-Verbose ($deliveries | Format-Table | Out-String) -Verbose
                $deliveries | Should -Not -BeNullOrEmpty
            }
            It 'Can redeliver a webhook delivery' {
                $deliveries = Get-GitHubAppWebhookDelivery | Select-Object -First 1
                { Invoke-GitHubAppWebhookReDelivery -ID $deliveries.id } | Should -Not -Throw
            }
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
    Context 'User' {
        It 'Can be called with Username parameter' {
            { Get-GitHubUser -Username 'Octocat' } | Should -Not -Throw
        }
    }
}
