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
    Context 'Actions' {
        It 'Get-GitHubEventData - Gets data about the event that triggered the workflow' {
            $workflow = Get-GitHubEventData
            Write-Verbose ($workflow | Format-Table | Out-String) -Verbose
            $workflow | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRunnerData - Gets data about the runner that is running the workflow' {
            $workflow = Get-GitHubRunnerData
            Write-Verbose ($workflow | Format-Table | Out-String) -Verbose
            $workflow | Should -Not -BeNullOrEmpty
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
            $context = Get-GitHubContext
            { $context | Disconnect-GitHubAccount } | Should -Not -Throw
        }
        It 'Connect-GitHubAccount - Connects GitHub Actions even if called multiple times' {
            { Connect-GitHubAccount } | Should -Not -Throw
            { Connect-GitHubAccount } | Should -Not -Throw
        }
        It 'Connect-GitHubAccount - Connects multiple contexts, GitHub Actions and a user via classic PAT token' {
            { Connect-GitHubAccount -Token $env:TEST_USER_PAT } | Should -Not -Throw
            { Connect-GitHubAccount -Token $env:TEST_USER_PAT } | Should -Not -Throw
            { Connect-GitHubAccount } | Should -Not -Throw
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
            $contexts = Get-GitHubContext -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 3
        }
        It 'Connect-GitHubAccount - Connects all of a (org) GitHub Apps installations' {
            $params = @{
                ClientID   = $env:TEST_APP_ORG_CLIENT_ID
                PrivateKey = $env:TEST_APP_ORG_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params -AutoloadInstallations } | Should -Not -Throw
            $contexts = Get-GitHubContext -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 7
        }
        It 'Connect-GitHubAccount - Connects a GitHub App from an enterprise' {
            $params = @{
                ClientID   = $env:TEST_APP_ENT_CLIENT_ID
                PrivateKey = $env:TEST_APP_ENT_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params } | Should -Not -Throw
            $contexts = Get-GitHubContext -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 8
        }
        It 'Connect-GitHubAccount - Connects all of a (ent) GitHub Apps installations' {
            $params = @{
                ClientID   = $env:TEST_APP_ENT_CLIENT_ID
                PrivateKey = $env:TEST_APP_ENT_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params -AutoloadInstallations } | Should -Not -Throw
            $contexts = Get-GitHubContext -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 12
        }
        It 'Disconnect-GitHubAccount - Disconnects a specific context' {
            { Disconnect-GitHubAccount -Context 'github.com/psmodule-enterprise-app/Organization/PSModule' -Silent } | Should -Not -Throw
            $contexts = Get-GitHubContext -Name 'github.com/psmodule-enterprise-app/*' -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 3
        }
    }
    Context 'DefaultContext' {
        BeforeAll {
            Connect-GitHub
        }
        It 'Set-GitHubDefaultContext - Can swap context to another' {
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
            { Set-GitHubDefaultContext -Context 'github.com/github-actions/Organization/PSModule' } | Should -Not -Throw
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/github-actions/Organization/PSModule'
        }

        It 'Set-GitHubDefaultContext - Can swap context to another using pipeline - String' {
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
            { 'github.com/psmodule-user' | Set-GitHubDefaultContext } | Should -Not -Throw
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/psmodule-user'
        }

        It 'Set-GitHubDefaultContext - Can swap context to another using pipeline - Context object' {
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
            { Get-GitHubContext -Context 'github.com/psmodule-org-app' | Set-GitHubDefaultContext } | Should -Not -Throw
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/psmodule-org-app'
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
        It 'Set-GitHubOutput + Simple string - Should not throw' {
            {
                Set-GitHubOutput -Name 'MyOutput' -Value 'MyValue'
            } | Should -Not -Throw
            (Get-GitHubOutput).result.MyOutput | Should -Be 'MyValue'
        }
        It 'Set-GitHubOutput + Multiline string - Should not throw' {
            {
                Set-GitHubOutput -Name 'MyOutput' -Value @'
This is a multiline
string
'@
            } | Should -Not -Throw
            (Get-GitHubOutput).result.MyOutput | Should -Be @'
This is a multiline
string
'@
        }
        It 'Set-GitHubOutput + SecureString - Should not throw' {
            {
                $secret = 'MyValue' | ConvertTo-SecureString -AsPlainText -Force
                Set-GitHubOutput -Name 'MySecret' -Value $secret
            } | Should -Not -Throw
            (Get-GitHubOutput).result.MySecret | Should -Be 'MyValue'
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
            (Get-GitHubOutput).result.Config | Should -BeLike ''
        }
        It 'Get-GitHubOutput - Should not throw' {
            {
                Get-GitHubOutput
            } | Should -Not -Throw
            Write-Verbose (Get-GitHubOutput | Format-List | Out-String) -Verbose
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
    Context 'IssueParser' {
        It 'ConvertFrom-IssueForm - Should return a PSCustomObject' {
            $issueTestFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'IssueForm.md'
            $data = Get-Content -Path $issueTestFilePath -Raw | ConvertFrom-IssueForm
            Write-Verbose ($data | Format-Table | Out-String) -Verbose
            $data | Should -BeOfType 'PSCustomObject'
        }

        It 'ConvertFrom-IssueForm -AsHashtable - Should return a hashtable' {
            $issueTestFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'IssueForm.md'
            $data = Get-Content -Path $issueTestFilePath -Raw | ConvertFrom-IssueForm -AsHashtable
            Write-Verbose ($data | Out-String) -Verbose
            $data | Should -BeOfType 'hashtable'
        }

        It "'Type with spaces' should contain 'Action'" {
            $issueTestFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'IssueForm.md'
            $data = Get-Content -Path $issueTestFilePath -Raw | ConvertFrom-IssueForm -AsHashtable
            Write-Verbose ($data['Type with spaces'] | Out-String) -Verbose
            $data.Keys | Should -Contain 'Type with spaces'
            $data['Type with spaces'] | Should -Be 'Action'
        }

        It "'Multiline' should contain a multiline string with 3 lines" {
            $issueTestFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'IssueForm.md'
            $data = Get-Content -Path $issueTestFilePath -Raw | ConvertFrom-IssueForm -AsHashtable
            Write-Verbose ($data['Multiline'] | Out-String) -Verbose
            $data.Keys | Should -Contain 'Multiline'
            $data['Multiline'] | Should -Be @'
test
is multi
line
'@
        }

        It "'OS' should contain a hashtable with 3 items" {
            $issueTestFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'IssueForm.md'
            $data = Get-Content -Path $issueTestFilePath -Raw | ConvertFrom-IssueForm -AsHashtable
            Write-Verbose ($data['OS'] | Out-String) -Verbose
            $data.Keys | Should -Contain 'OS'
            $data['OS'].Windows | Should -BeTrue
            $data['OS'].Linux | Should -BeTrue
            $data['OS'].Mac | Should -BeFalse
        }
    }
    Context 'Disconnect' {
        It 'Disconnect-GitHubAccount - Can disconnect all context through the pipeline' {
            { Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount } | Should -Not -Throw
            Get-GitHubContext -ListAvailable | Should -HaveCount 0
        }
    }
}

Describe 'As a user - Fine-grained PAT token - user account access (USER_FG_PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_USER_FG_PAT
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Auth' {
        It 'Get-GitHubViewer - Gets the logged in context (USER_FG_PAT)' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
    }
    Context 'API' {
        It 'Invoke-GitHubAPI - Gets the rate limits directly (USER_FG_PAT)' {
            {
                $rateLimit = Invoke-GitHubAPI -ApiEndpoint '/rate_limit'
                Write-Verbose ($rateLimit | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
    Context 'GraphQL' {
        It 'Invoke-GitHubGraphQLQuery - Gets the viewer directly (USER_FG_PAT)' {
            {
                $viewer = Invoke-GitHubGraphQLQuery -Query 'query { viewer { login } }'
                Write-Verbose ($viewer | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
    Context 'Meta' {
        It 'Get-GitHubRoot - Gets the GitHub API Root (USER_FG_PAT)' {
            $root = Get-GitHubRoot
            Write-Verbose ($root | Format-Table | Out-String) -Verbose
            $root | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubApiVersion - Gets all API versions (USER_FG_PAT)' {
            $apiVersion = Get-GitHubApiVersion
            Write-Verbose ($apiVersion | Format-Table | Out-String) -Verbose
            $apiVersion | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubMeta - Gets GitHub meta information (USER_FG_PAT)' {
            $meta = Get-GitHubMeta
            Write-Verbose ($meta | Format-Table | Out-String) -Verbose
            $meta | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubOctocat - Gets the Octocat (USER_FG_PAT)' {
            $octocat = Get-GitHubOctocat
            Write-Verbose ($octocat | Format-Table | Out-String) -Verbose
            $octocat | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubZen - Gets the Zen of GitHub (USER_FG_PAT)' {
            $zen = Get-GitHubZen
            Write-Verbose ($zen | Format-Table | Out-String) -Verbose
            $zen | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Rate-Limit' {
        It 'Get-GitHubRateLimit - Gets the rate limit status for the authenticated user (USER_FG_PAT)' {
            { Get-GitHubRateLimit } | Should -Not -Throw
        }
    }
    Context 'License' {
        It 'Get-GitHubLicense - Gets a list of all popular license templates (USER_FG_PAT)' {
            { Get-GitHubLicense } | Should -Not -Throw
        }
        It 'Get-GitHubLicense - Gets a spesific license (USER_FG_PAT)' {
            { Get-GitHubLicense -Name 'mit' } | Should -Not -Throw
        }
        It 'Get-GitHubLicense - Gets a license from a repository (USER_FG_PAT)' {
            { Get-GitHubLicense -Owner 'PSModule' -Repo 'GitHub' } | Should -Not -Throw
        }
    }
    Context 'Emoji' {
        It 'Get-GitHubEmoji - Gets a list of all emojis (USER_FG_PAT)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (USER_FG_PAT)' {
            { Get-GitHubEmoji -Destination $Home } | Should -Not -Throw
        }
    }
    Context 'Repository' {
        It "Get-GitHubRepository - Gets the authenticated user's repositories (USER_FG_PAT)" {
            { Get-GitHubRepository } | Should -Not -Throw
        }
        It "Get-GitHubRepository - Gets the authenticated user's public repositories (USER_FG_PAT)" {
            { Get-GitHubRepository -Type 'public' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets the public repos where the authenticated user is owner (USER_FG_PAT)' {
            { Get-GitHubRepository -Visibility 'public' -Affiliation 'owner' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets a specific repository (USER_FG_PAT)' {
            { Get-GitHubRepository -Owner 'PSModule' -Repo 'GitHub' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets all repositories from a organization (USER_FG_PAT)' {
            { Get-GitHubRepository -Owner 'PSModule' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets all repositories from a user (USER_FG_PAT)' {
            { Get-GitHubRepository -Username 'MariusStorhaug' } | Should -Not -Throw
        }
    }
    Context 'GitIgnore' {
        It 'Get-GitHubGitignore - Gets a list of all gitignore templates names (USER_FG_PAT)' {
            { Get-GitHubGitignore } | Should -Not -Throw
        }
        It 'Get-GitHubGitignore - Gets a gitignore template (USER_FG_PAT)' {
            { Get-GitHubGitignore -Name 'VisualStudio' } | Should -Not -Throw
        }
    }
    Context 'Markdown' {
        It 'Get-GitHubMarkdown - Gets the rendered markdown for provided text (USER_FG_PAT)' {
            { Get-GitHubMarkdown -Text 'Hello, World!' } | Should -Not -Throw
        }
        It 'Get-GitHubMarkdown - Gets the rendered markdown for provided text using GitHub Formated Markdown (USER_FG_PAT)' {
            { Get-GitHubMarkdown -Text 'Hello, World!' -Mode gfm } | Should -Not -Throw
        }
        It 'Get-GitHubMarkdownRaw - Gets the raw rendered markdown for provided text (USER_FG_PAT)' {
            { Get-GitHubMarkdownRaw -Text 'Hello, World!' } | Should -Not -Throw
        }
    }
    Context 'User' {
        It 'Get-GitHubUser - Gets the authenticated user (USER_FG_PAT)' {
            { Get-GitHubUser } | Should -Not -Throw
        }
        It 'Get-GitHubUser - Get the specified user (USER_FG_PAT)' {
            { Get-GitHubUser -Username 'Octocat' } | Should -Not -Throw
        }
        It 'Update-GitHubUser - Can set configuration on a user (USER_FG_PAT)' {
            $guid = (New-Guid).Guid
            $user = Get-GitHubUser
            { Update-GitHubUser -Name 'Octocat' } | Should -Not -Throw
            { Update-GitHubUser -Blog 'https://psmodule.io' } | Should -Not -Throw
            { Update-GitHubUser -TwitterUsername $guid } | Should -Not -Throw
            { Update-GitHubUser -Company 'PSModule' } | Should -Not -Throw
            { Update-GitHubUser -Location 'USA' } | Should -Not -Throw
            { Update-GitHubUser -Bio 'I love programming' } | Should -Not -Throw
            $tmpUser = Get-GitHubUser
            $tmpUser.name | Should -Be 'Octocat'
            $tmpUser.blog | Should -Be 'https://psmodule.io'
            $tmpUser.twitter_username | Should -Be $guid
            $tmpUser.company | Should -Be 'PSModule'
            $tmpUser.location | Should -Be 'USA'
            $tmpUser.bio | Should -Be 'I love programming'
        }
        Context 'Email' {
            It 'Get-GitHubUserEmail - Gets all email addresses for the authenticated user (USER_FG_PAT)' {
                { Get-GitHubUserEmail } | Should -Not -Throw
            }
            It 'Add/Remove-GitHubUserEmail - Adds and removes an email to the authenticated user (USER_FG_PAT)' {
                $email = (New-Guid).Guid + '@psmodule.io'
                { Add-GitHubUserEmail -Emails $email } | Should -Not -Throw
                (Get-GitHubUserEmail).email | Should -Contain $email
                { Remove-GitHubUserEmail -Emails $email } | Should -Not -Throw
                (Get-GitHubUserEmail).email | Should -Not -Contain $email
            }
        }
    }
}

Describe 'As a user - Fine-grained PAT token - organization account access (ORG_FG_PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_ORG_FG_PAT
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Auth' {
        It 'Get-GitHubViewer - Gets the logged in context (ORG_FG_PAT)' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
    }
    Context 'API' {
        It 'Invoke-GitHubAPI - Gets the rate limits directly (ORG_FG_PAT)' {
            {
                $rateLimit = Invoke-GitHubAPI -ApiEndpoint '/rate_limit'
                Write-Verbose ($rateLimit | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
    Context 'GraphQL' {
        It 'Invoke-GitHubGraphQLQuery - Gets the viewer directly (ORG_FG_PAT)' {
            {
                $viewer = Invoke-GitHubGraphQLQuery -Query 'query { viewer { login } }'
                Write-Verbose ($viewer | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
    Context 'Meta' {
        It 'Get-GitHubRoot - Gets the GitHub API Root (ORG_FG_PAT)' {
            $root = Get-GitHubRoot
            Write-Verbose ($root | Format-Table | Out-String) -Verbose
            $root | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubApiVersion - Gets all API versions (ORG_FG_PAT)' {
            $apiVersion = Get-GitHubApiVersion
            Write-Verbose ($apiVersion | Format-Table | Out-String) -Verbose
            $apiVersion | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubMeta - Gets GitHub meta information (ORG_FG_PAT)' {
            $meta = Get-GitHubMeta
            Write-Verbose ($meta | Format-Table | Out-String) -Verbose
            $meta | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubOctocat - Gets the Octocat (ORG_FG_PAT)' {
            $octocat = Get-GitHubOctocat
            Write-Verbose ($octocat | Format-Table | Out-String) -Verbose
            $octocat | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubZen - Gets the Zen of GitHub (ORG_FG_PAT)' {
            $zen = Get-GitHubZen
            Write-Verbose ($zen | Format-Table | Out-String) -Verbose
            $zen | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Rate-Limit' {
        It 'Get-GitHubRateLimit - Gets the rate limit status for the authenticated user (ORG_FG_PAT)' {
            { Get-GitHubRateLimit } | Should -Not -Throw
        }
    }
    Context 'License' {
        It 'Get-GitHubLicense - Gets a list of all popular license templates (ORG_FG_PAT)' {
            { Get-GitHubLicense } | Should -Not -Throw
        }
        It 'Get-GitHubLicense - Gets a spesific license (ORG_FG_PAT)' {
            { Get-GitHubLicense -Name 'mit' } | Should -Not -Throw
        }
        It 'Get-GitHubLicense - Gets a license from a repository (ORG_FG_PAT)' {
            { Get-GitHubLicense -Owner 'PSModule' -Repo 'GitHub' } | Should -Not -Throw
        }
    }
    Context 'Emoji' {
        It 'Get-GitHubEmoji - Gets a list of all emojis (ORG_FG_PAT)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (ORG_FG_PAT)' {
            { Get-GitHubEmoji -Destination $Home } | Should -Not -Throw
        }
    }
    Context 'Repository' {
        It "Get-GitHubRepository - Gets the authenticated user's repositories (ORG_FG_PAT)" {
            { Get-GitHubRepository } | Should -Not -Throw
        }
        It "Get-GitHubRepository - Gets the authenticated user's public repositories (ORG_FG_PAT)" {
            { Get-GitHubRepository -Type 'public' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets the public repos where the authenticated user is owner (ORG_FG_PAT)' {
            { Get-GitHubRepository -Visibility 'public' -Affiliation 'owner' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets a specific repository (ORG_FG_PAT)' {
            { Get-GitHubRepository -Owner 'PSModule' -Repo 'GitHub' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets all repositories from a organization (ORG_FG_PAT)' {
            { Get-GitHubRepository -Owner 'PSModule' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets all repositories from a user (ORG_FG_PAT)' {
            { Get-GitHubRepository -Username 'MariusStorhaug' } | Should -Not -Throw
        }
    }
    Context 'GitIgnore' {
        It 'Get-GitHubGitignore - Gets a list of all gitignore templates names (ORG_FG_PAT)' {
            { Get-GitHubGitignore } | Should -Not -Throw
        }
        It 'Get-GitHubGitignore - Gets a gitignore template (ORG_FG_PAT)' {
            { Get-GitHubGitignore -Name 'VisualStudio' } | Should -Not -Throw
        }
    }
    Context 'Markdown' {
        It 'Get-GitHubMarkdown - Gets the rendered markdown for provided text (ORG_FG_PAT)' {
            { Get-GitHubMarkdown -Text 'Hello, World!' } | Should -Not -Throw
        }
        It 'Get-GitHubMarkdown - Gets the rendered markdown for provided text using GitHub Formated Markdown (ORG_FG_PAT)' {
            { Get-GitHubMarkdown -Text 'Hello, World!' -Mode gfm } | Should -Not -Throw
        }
        It 'Get-GitHubMarkdownRaw - Gets the raw rendered markdown for provided text (ORG_FG_PAT)' {
            { Get-GitHubMarkdownRaw -Text 'Hello, World!' } | Should -Not -Throw
        }
    }
    Context 'User' {
        It 'Get-GitHubUser - Gets the authenticated user (ORG_FG_PAT)' {
            { Get-GitHubUser } | Should -Not -Throw
        }
        It 'Get-GitHubUser - Get the specified user (ORG_FG_PAT)' {
            { Get-GitHubUser -Username 'Octocat' } | Should -Not -Throw
        }
    }
    Context 'Organization' {
        It 'Get-GitHubOrganization - Gets the organizations for the authenticated user (ORG_FG_PAT)' {
            { Get-GitHubOrganization } | Should -Not -Throw
        }
        It 'Get-GitHubOrganization - Gets a specific organization (ORG_FG_PAT)' {
            { Get-GitHubOrganization -Organization 'psmodule-test-org2' } | Should -Not -Throw
        }
        It "Get-GitHubOrganization - List public organizations for the user 'psmodule-user'. (ORG_FG_PAT)" {
            { Get-GitHubOrganization -Username 'psmodule-user' } | Should -Not -Throw
        }
        It 'Get-GitHubOrganizationMember - Gets the members of a specific organization (ORG_FG_PAT)' {
            $members = Get-GitHubOrganizationMember -Organization 'psmodule-test-org2'
            $members.login | Should -Contain 'psmodule-user'
        }
        It 'Update-GitHubOrganization - Sets the organization configuration (ORG_FG_PAT)' {
            { Update-GitHubOrganization -Organization 'psmodule-test-org2' -Company 'ABC' } | Should -Not -Throw
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                Update-GitHubOrganization -Organization 'psmodule-test-org2' -BillingEmail $email
            } | Should -Not -Throw
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                Update-GitHubOrganization -Organization 'psmodule-test-org2' -Email $email
            } | Should -Not -Throw
            {
                $guid = (New-Guid).Guid
                Update-GitHubOrganization -Organization 'psmodule-test-org2' -TwitterUsername $guid
            } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org2' -Location 'USA' } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org2' -Description 'Test Organization' } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org2' -DefaultRepositoryPermission read } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org2' -MembersCanCreateRepositories $true } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org2' -Blog 'https://psmodule.io' } | Should -Not -Throw
        }
        It 'New-GitHubOrganizationInvitation - Invites a user to an organization (ORG_FG_PAT)' {
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                New-GitHubOrganizationInvitation -Organization 'psmodule-test-org2' -Email $email -Role 'admin'
            } | Should -Not -Throw
        }
        It 'Get-GitHubOrganizationPendingInvitation - Gets the pending invitations for a specific organization (ORG_FG_PAT)' {
            { Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org2' } | Should -Not -Throw
            { Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org2' -Role 'admin' } | Should -Not -Throw
            { Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org2' -InvitationSource 'member' } | Should -Not -Throw
        }
        It 'Remove-GitHubOrganizationInvitation - Removes a user invitation from an organization (ORG_FG_PAT)' {
            {
                $invitation = Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org2' | Select-Object -First 1
                Remove-GitHubOrganizationInvitation -Organization 'psmodule-test-org2' -ID $invitation.id
            } | Should -Not -Throw
        }
    }
}

Describe 'As a user - Classic PAT token (PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_PAT
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Auth' {
        It 'Get-GitHubViewer - Gets the logged in context (PAT)' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
    }
    Context 'API' {
        It 'Invoke-GitHubAPI - Gets the rate limits directly (PAT)' {
            {
                $rateLimit = Invoke-GitHubAPI -ApiEndpoint '/rate_limit'
                Write-Verbose ($rateLimit | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
    Context 'GraphQL' {
        It 'Invoke-GitHubGraphQLQuery - Gets the viewer directly (PAT)' {
            {
                $viewer = Invoke-GitHubGraphQLQuery -Query 'query { viewer { login } }'
                Write-Verbose ($viewer | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
    Context 'Meta' {
        It 'Get-GitHubRoot - Gets the GitHub API Root (PAT)' {
            $root = Get-GitHubRoot
            Write-Verbose ($root | Format-Table | Out-String) -Verbose
            $root | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubApiVersion - Gets all API versions (PAT)' {
            $apiVersion = Get-GitHubApiVersion
            Write-Verbose ($apiVersion | Format-Table | Out-String) -Verbose
            $apiVersion | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubMeta - Gets GitHub meta information (PAT)' {
            $meta = Get-GitHubMeta
            Write-Verbose ($meta | Format-Table | Out-String) -Verbose
            $meta | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubOctocat - Gets the Octocat (PAT)' {
            $octocat = Get-GitHubOctocat
            Write-Verbose ($octocat | Format-Table | Out-String) -Verbose
            $octocat | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubZen - Gets the Zen of GitHub (PAT)' {
            $zen = Get-GitHubZen
            Write-Verbose ($zen | Format-Table | Out-String) -Verbose
            $zen | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Rate-Limit' {
        It 'Get-GitHubRateLimit - Gets the rate limit status for the authenticated user (PAT)' {
            { Get-GitHubRateLimit } | Should -Not -Throw
        }
    }
    Context 'License' {
        It 'Get-GitHubLicense - Gets a list of all popular license templates (PAT)' {
            { Get-GitHubLicense } | Should -Not -Throw
        }
        It 'Get-GitHubLicense - Gets a spesific license (PAT)' {
            { Get-GitHubLicense -Name 'mit' } | Should -Not -Throw
        }
        It 'Get-GitHubLicense - Gets a license from a repository (PAT)' {
            { Get-GitHubLicense -Owner 'PSModule' -Repo 'GitHub' } | Should -Not -Throw
        }
    }
    Context 'Emoji' {
        It 'Get-GitHubEmoji - Gets a list of all emojis (PAT)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (PAT)' {
            { Get-GitHubEmoji -Destination $Home } | Should -Not -Throw
        }
    }
    Context 'GitIgnore' {
        It 'Get-GitHubGitignore - Gets a list of all gitignore templates names (PAT)' {
            { Get-GitHubGitignore } | Should -Not -Throw
        }
        It 'Get-GitHubGitignore - Gets a gitignore template (PAT)' {
            { Get-GitHubGitignore -Name 'VisualStudio' } | Should -Not -Throw
        }
    }
    Context 'Markdown' {
        It 'Get-GitHubMarkdown - Gets the rendered markdown for provided text (PAT)' {
            { Get-GitHubMarkdown -Text 'Hello, World!' } | Should -Not -Throw
        }
        It 'Get-GitHubMarkdown - Gets the rendered markdown for provided text using GitHub Formated Markdown (PAT)' {
            { Get-GitHubMarkdown -Text 'Hello, World!' -Mode gfm } | Should -Not -Throw
        }
        It 'Get-GitHubMarkdownRaw - Gets the raw rendered markdown for provided text (PAT)' {
            { Get-GitHubMarkdownRaw -Text 'Hello, World!' } | Should -Not -Throw
        }
    }
    Context 'User' {
        It 'Get-GitHubUser - Gets the authenticated user (PAT)' {
            { Get-GitHubUser } | Should -Not -Throw
        }
        It 'Get-GitHubUser - Get the specified user (PAT)' {
            { Get-GitHubUser -Username 'Octocat' } | Should -Not -Throw
        }
        It 'Update-GitHubUser - Can set configuration on a user (PAT)' {
            $guid = (New-Guid).Guid
            $user = Get-GitHubUser
            { Update-GitHubUser -Name 'Octocat' } | Should -Not -Throw
            { Update-GitHubUser -Blog 'https://psmodule.io' } | Should -Not -Throw
            { Update-GitHubUser -TwitterUsername $guid } | Should -Not -Throw
            { Update-GitHubUser -Company 'PSModule' } | Should -Not -Throw
            { Update-GitHubUser -Location 'USA' } | Should -Not -Throw
            { Update-GitHubUser -Bio 'I love programming' } | Should -Not -Throw
            $tmpUser = Get-GitHubUser
            $tmpUser.name | Should -Be 'Octocat'
            $tmpUser.blog | Should -Be 'https://psmodule.io'
            $tmpUser.twitter_username | Should -Be $guid
            $tmpUser.company | Should -Be 'PSModule'
            $tmpUser.location | Should -Be 'USA'
            $tmpUser.bio | Should -Be 'I love programming'
        }
        Context 'Email' {
            It 'Get-GitHubUserEmail - Gets all email addresses for the authenticated user (PAT)' {
                { Get-GitHubUserEmail } | Should -Not -Throw
            }
            It 'Add/Remove-GitHubUserEmail - Adds and removes an email to the authenticated user (PAT)' {
                $email = (New-Guid).Guid + '@psmodule.io'
                { Add-GitHubUserEmail -Emails $email } | Should -Not -Throw
                (Get-GitHubUserEmail).email | Should -Contain $email
                { Remove-GitHubUserEmail -Emails $email } | Should -Not -Throw
                (Get-GitHubUserEmail).email | Should -Not -Contain $email
            }
        }
    }
    Context 'Organization' {
        It 'Get-GitHubOrganization - Gets the organizations for the authenticated user (PAT)' {
            { Get-GitHubOrganization } | Should -Not -Throw
        }
        It 'Get-GitHubOrganization - Gets a specific organization (PAT)' {
            { Get-GitHubOrganization -Organization 'psmodule-test-org2' } | Should -Not -Throw
        }
        It "Get-GitHubOrganization - List public organizations for the user 'psmodule-user'. (PAT)" {
            { Get-GitHubOrganization -Username 'psmodule-user' } | Should -Not -Throw
        }
        It 'Get-GitHubOrganizationMember - Gets the members of a specific organization (PAT)' {
            $members = Get-GitHubOrganizationMember -Organization 'psmodule-test-org2'
            $members.login | Should -Contain 'psmodule-user'
        }
    }
}

Describe 'As GitHub Actions (GHA)' {
    BeforeAll {
        Connect-GitHubAccount
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Auth' {
        It 'Get-GitHubViewer - Gets the logged in context (GHA)' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
    }
    Context 'API' {
        It 'Invoke-GitHubAPI - Gets the rate limits directly (GHA)' {
            {
                $rateLimit = Invoke-GitHubAPI -ApiEndpoint '/rate_limit'
                Write-Verbose ($rateLimit | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
    Context 'GraphQL' {
        It 'Invoke-GitHubGraphQLQuery - Gets the viewer directly (GHA)' {
            {
                $viewer = Invoke-GitHubGraphQLQuery -Query 'query { viewer { login } }'
                Write-Verbose ($viewer | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
    Context 'Git' {
        It "Get-GitHubGitConfig gets the 'local' (default) Git configuration (GHA)" {
            $gitConfig = Get-GitHubGitConfig
            Write-Verbose ($gitConfig | Format-List | Out-String) -Verbose
            $gitConfig | Should -Not -BeNullOrEmpty
        }
        It "Get-GitHubGitConfig gets the 'global' Git configuration (GHA)" {
            git config --global advice.pushfetchfirst false
            $gitConfig = Get-GitHubGitConfig -Scope 'global'
            Write-Verbose ($gitConfig | Format-List | Out-String) -Verbose
            $gitConfig | Should -Not -BeNullOrEmpty
        }
        It "Get-GitHubGitConfig gets the 'system' Git configuration (GHA)" {
            $gitConfig = Get-GitHubGitConfig -Scope 'system'
            Write-Verbose ($gitConfig | Format-List | Out-String) -Verbose
            $gitConfig | Should -Not -BeNullOrEmpty
        }
        It 'Set-GitHubGitConfig sets the Git configuration (GHA)' {
            { Set-GitHubGitConfig } | Should -Not -Throw
            $gitConfig = Get-GitHubGitConfig -Scope 'global'
            Write-Verbose ($gitConfig | Format-List | Out-String) -Verbose

            $gitConfig | Should -Not -BeNullOrEmpty
            $gitConfig.'user.name' | Should -Not -BeNullOrEmpty
            $gitConfig.'user.email' | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Meta' {
        It 'Get-GitHubRoot - Gets the GitHub API Root (GHA)' {
            $root = Get-GitHubRoot
            Write-Verbose ($root | Format-Table | Out-String) -Verbose
            $root | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubApiVersion - Gets all API versions (GHA)' {
            $apiVersion = Get-GitHubApiVersion
            Write-Verbose ($apiVersion | Format-Table | Out-String) -Verbose
            $apiVersion | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubMeta - Gets GitHub meta information (GHA)' {
            $meta = Get-GitHubMeta
            Write-Verbose ($meta | Format-Table | Out-String) -Verbose
            $meta | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubOctocat - Gets the Octocat (GHA)' {
            $octocat = Get-GitHubOctocat
            Write-Verbose ($octocat | Format-Table | Out-String) -Verbose
            $octocat | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubZen - Gets the Zen of GitHub (GHA)' {
            $zen = Get-GitHubZen
            Write-Verbose ($zen | Format-Table | Out-String) -Verbose
            $zen | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Rate-Limit' {
        It 'Get-GitHubRateLimit - Gets the rate limit status for the authenticated user (GHA)' {
            { Get-GitHubRateLimit } | Should -Not -Throw
        }
    }
    Context 'License' {
        It 'Get-GitHubLicense - Gets a list of all popular license templates (GHA)' {
            { Get-GitHubLicense } | Should -Not -Throw
        }
        It 'Get-GitHubLicense - Gets a spesific license (GHA)' {
            { Get-GitHubLicense -Name 'mit' } | Should -Not -Throw
        }
        It 'Get-GitHubLicense - Gets a license from a repository (GHA)' {
            { Get-GitHubLicense -Owner 'PSModule' -Repo 'GitHub' } | Should -Not -Throw
        }
    }
    Context 'Emoji' {
        It 'Get-GitHubEmoji - Gets a list of all emojis (GHA)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (GHA)' {
            { Get-GitHubEmoji -Destination $Home } | Should -Not -Throw
        }
    }
    Context 'GitIgnore' {
        It 'Get-GitHubGitignore - Gets a list of all gitignore templates names (GHA)' {
            { Get-GitHubGitignore } | Should -Not -Throw
        }
        It 'Get-GitHubGitignore - Gets a gitignore template (GHA)' {
            { Get-GitHubGitignore -Name 'VisualStudio' } | Should -Not -Throw
        }
    }
    Context 'Markdown' {
        It 'Get-GitHubMarkdown - Gets the rendered markdown for provided text (GHA)' {
            { Get-GitHubMarkdown -Text 'Hello, World!' } | Should -Not -Throw
        }
        It 'Get-GitHubMarkdown - Gets the rendered markdown for provided text using GitHub Formated Markdown (GHA)' {
            { Get-GitHubMarkdown -Text 'Hello, World!' -Mode gfm } | Should -Not -Throw
        }
        It 'Get-GitHubMarkdownRaw - Gets the raw rendered markdown for provided text (GHA)' {
            { Get-GitHubMarkdownRaw -Text 'Hello, World!' } | Should -Not -Throw
        }
    }
    Context 'User' {
        It 'Get-GitHubUser - Get the specified user (GHA)' {
            { Get-GitHubUser -Username 'Octocat' } | Should -Not -Throw
        }
    }
}

Describe 'As a GitHub App - Enterprise (APP_ENT)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ENT_CLIENT_ID -PrivateKey $env:TEST_APP_ENT_PRIVATE_KEY
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Auth' {
        # It 'Connect-GitHubApp - Connects one enterprise installation for the authenticated GitHub App (APP_ENT)' {
        #     $context = Get-GitHubContext
        #     { Connect-GitHubApp -Enterprise msx -Context $context } | Should -Not -Throw
        #     Get-GitHubContext -ListAvailable | Should -HaveCount 2
        # }
        It 'Connect-GitHubApp - Connects one organization installation for the authenticated GitHub App (APP_ENT)' {
            $context = Connect-GitHubApp -Organization AzActions -PassThru
            $context.Name | Should -BeLike '*/Organization/AzActions'
            Get-GitHubContext -ListAvailable | Should -HaveCount 2
        }
        It 'Connect-GitHubApp - Connects all installations for the authenticated GitHub App (APP_ENT)' {
            { Connect-GitHubApp } | Should -Not -Throw
            Get-GitHubContext -ListAvailable | Should -HaveCount 5
        }
    }
    Context 'App' {
        It 'Get-GitHubApp - Can get the authenticated GitHubApp (APP_ENT)' {
            $app = Get-GitHubApp
            Write-Verbose ($app | Format-Table | Out-String) -Verbose
            $app | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Organization' {
        BeforeAll {
            Connect-GitHubApp -Organization 'psmodule-test-org3' -Default
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
        It 'Get-GitHubOrganization - Gets a specific organization (APP_ENT)' {
            { Get-GitHubOrganization -Organization 'psmodule-test-org3' } | Should -Not -Throw
        }
        It 'Get-GitHubOrganizationAppInstallation - Gets the GitHub App installations on the organization (APP_ENT)' {
            $installations = Get-GitHubOrganizationAppInstallation -Organization 'psmodule-test-org3'
            Write-Verbose ($installations | Format-Table | Out-String) -Verbose
            $installations | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubOrganizationMember - Gets the members of a specific organization (APP_ENT)' {
            $members = Get-GitHubOrganizationMember -Organization 'psmodule-test-org3'
            $members.login | Should -Contain 'MariusStorhaug'
        }
        It 'Update-GitHubOrganization - Sets the organization configuration (APP_ENT)' {
            { Update-GitHubOrganization -Organization 'psmodule-test-org3' -Company 'ABC' } | Should -Not -Throw
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                Update-GitHubOrganization -Organization 'psmodule-test-org3' -BillingEmail $email
            } | Should -Not -Throw
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                Update-GitHubOrganization -Organization 'psmodule-test-org3' -Email $email
            } | Should -Not -Throw
            {
                $guid = (New-Guid).Guid
                Update-GitHubOrganization -Organization 'psmodule-test-org3' -TwitterUsername $guid
            } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org3' -Location 'USA' } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org3' -Description 'Test Organization' } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org3' -DefaultRepositoryPermission read } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org3' -MembersCanCreateRepositories $true } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org3' -Blog 'https://psmodule.io' } | Should -Not -Throw
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
    Context 'Auth' {
        It 'Connect-GitHubApp - Connects one user installation for the authenticated GitHub App (APP_ORG)' {
            $context = Get-GitHubContext
            { Connect-GitHubApp -User MariusStorhaug -Context $context } | Should -Not -Throw
            Get-GitHubContext -ListAvailable | Should -HaveCount 2
        }
        It 'Connect-GitHubApp - Connects one organization installation for the authenticated GitHub App (APP_ORG)' {
            $context = Connect-GitHubApp -Organization AzActions -PassThru
            $context.Name | Should -BeLike '*/Organization/AzActions'
            Get-GitHubContext -ListAvailable | Should -HaveCount 3
        }
        It 'Connect-GitHubApp - Connects all installations for the authenticated GitHub App (APP_ORG)' {
            { Connect-GitHubApp } | Should -Not -Throw
            Get-GitHubContext -ListAvailable | Should -HaveCount 5
        }
    }
    Context 'Apps' {
        Context 'GitHub Apps' {
            It 'Can get a JWT for the app (APP_ENT)' {
                $jwt = Get-GitHubAppJSONWebToken -ClientId $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
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
    Context 'API' {
        It 'Can be called directly to get ratelimits (APP_ENT)' {
            {
                $app = Invoke-GitHubAPI -ApiEndpoint '/app'
                Write-Verbose ($app | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
    Context 'Organization' {
        BeforeAll {
            Connect-GitHubApp -Organization 'psmodule-test-org' -Default
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
        It 'Get-GitHubOrganization - Gets a specific organization (APP_ORG)' {
            { Get-GitHubOrganization -Organization 'psmodule-test-org' } | Should -Not -Throw
        }
        It 'Get-GitHubOrganizationAppInstallation - Gets the GitHub App installations on the organization (APP_ORG)' {
            $installations = Get-GitHubOrganizationAppInstallation -Organization 'psmodule-test-org'
            Write-Verbose ($installations | Format-Table | Out-String) -Verbose
            $installations | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubOrganizationMember - Gets the members of a specific organization (APP_ORG)' {
            $members = Get-GitHubOrganizationMember -Organization 'psmodule-test-org'
            $members.login | Should -Contain 'MariusStorhaug'
        }
        It 'Update-GitHubOrganization - Sets the organization configuration (APP_ORG)' {
            { Update-GitHubOrganization -Organization 'psmodule-test-org' -Company 'ABC' } | Should -Not -Throw
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                Update-GitHubOrganization -Organization 'psmodule-test-org' -BillingEmail $email
            } | Should -Not -Throw
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                Update-GitHubOrganization -Organization 'psmodule-test-org' -Email $email
            } | Should -Not -Throw
            {
                $guid = (New-Guid).Guid
                Update-GitHubOrganization -Organization 'psmodule-test-org' -TwitterUsername $guid
            } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org' -Location 'USA' } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org' -Description 'Test Organization' } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org' -DefaultRepositoryPermission read } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org' -MembersCanCreateRepositories $true } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org' -Blog 'https://psmodule.io' } | Should -Not -Throw
        }
        It 'New-GitHubOrganizationInvitation - Invites a user to an organization (APP_ORG)' {
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                New-GitHubOrganizationInvitation -Organization 'psmodule-test-org' -Email $email -Role 'admin'
            } | Should -Not -Throw
        }
        It 'Get-GitHubOrganizationPendingInvitation - Gets the pending invitations for a specific organization (APP_ORG)' {
            { Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org' } | Should -Not -Throw
            { Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org' -Role 'admin' } | Should -Not -Throw
            { Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org' -InvitationSource 'member' } | Should -Not -Throw
        }
        It 'Remove-GitHubOrganizationInvitation - Removes a user invitation from an organization (APP_ORG)' {
            {
                $invitation = Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org' | Select-Object -First 1
                Remove-GitHubOrganizationInvitation -Organization 'psmodule-test-org' -ID $invitation.id
            } | Should -Not -Throw
        }
    }
}
