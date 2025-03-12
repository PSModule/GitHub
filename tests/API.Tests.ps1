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

Describe 'As a user - Fine-grained PAT token - user account access (USER_FG_PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_USER_FG_PAT
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
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
            { Get-GitHubLicense -Owner 'PSModule' -Repository 'GitHub' } | Should -Not -Throw
        }
    }
    Context 'Emoji' {
        It 'Get-GitHubEmoji - Gets a list of all emojis (USER_FG_PAT)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (USER_FG_PAT)' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
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
            { Get-GitHubRepository -Owner 'PSModule' -Repository 'GitHub' } | Should -Not -Throw
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
}

Describe 'As a user - Fine-grained PAT token - organization account access (ORG_FG_PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_ORG_FG_PAT
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
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
            { Get-GitHubLicense -Owner 'PSModule' -Repository 'GitHub' } | Should -Not -Throw
        }
    }
    Context 'Emoji' {
        It 'Get-GitHubEmoji - Gets a list of all emojis (ORG_FG_PAT)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (ORG_FG_PAT)' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
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
            { Get-GitHubRepository -Owner 'PSModule' -Repository 'GitHub' } | Should -Not -Throw
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
}

Describe 'As a user - Classic PAT token (PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_PAT
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
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
            { Get-GitHubLicense -Owner 'PSModule' -Repository 'GitHub' } | Should -Not -Throw
        }
    }
    Context 'Emoji' {
        It 'Get-GitHubEmoji - Gets a list of all emojis (PAT)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (PAT)' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
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
}

Describe 'As GitHub Actions (GHA)' {
    BeforeAll {
        Connect-GitHubAccount
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
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
            { Get-GitHubLicense -Owner 'PSModule' -Repository 'GitHub' } | Should -Not -Throw
        }
    }
    Context 'Emoji' {
        It 'Get-GitHubEmoji - Gets a list of all emojis (GHA)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (GHA)' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
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
}

Describe 'As a GitHub App - Enterprise (APP_ENT)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ENT_CLIENT_ID -PrivateKey $env:TEST_APP_ENT_PRIVATE_KEY
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'API' {
        It 'Can be called directly to get ratelimits (APP_ENT)' {
            {
                $app = Invoke-GitHubAPI -ApiEndpoint '/app'
                Write-Verbose ($app | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
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
    Context 'API' {
        It 'Can be called directly to get ratelimits (APP_ENT)' {
            {
                $app = Invoke-GitHubAPI -ApiEndpoint '/app'
                Write-Verbose ($app | Format-Table | Out-String) -Verbose
            } | Should -Not -Throw
        }
    }
}
