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
            { Get-GitHubRepository -Owner 'PSModule' -Name 'GitHub' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets all repositories from a organization (USER_FG_PAT)' {
            { Get-GitHubRepository -Owner 'PSModule' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets all repositories from a user (USER_FG_PAT)' {
            { Get-GitHubRepository -Username 'MariusStorhaug' } | Should -Not -Throw
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
            { Get-GitHubRepository -Owner 'PSModule' -Name 'GitHub' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets all repositories from a organization (ORG_FG_PAT)' {
            { Get-GitHubRepository -Owner 'PSModule' } | Should -Not -Throw
        }
        It 'Get-GitHubRepository - Gets all repositories from a user (ORG_FG_PAT)' {
            { Get-GitHubRepository -Username 'MariusStorhaug' } | Should -Not -Throw
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
}

Describe 'As GitHub Actions (GHA)' {
    BeforeAll {
        Connect-GitHubAccount
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
}

Describe 'As a GitHub App - Enterprise (APP_ENT)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ENT_CLIENT_ID -PrivateKey $env:TEST_APP_ENT_PRIVATE_KEY
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
}

Describe 'As a GitHub App - Organization (APP_ORG)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
}
