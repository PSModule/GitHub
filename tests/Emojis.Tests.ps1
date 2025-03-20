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

Describe 'Emoji' {
    Context 'As a user - Fine-grained PAT token - user account access (USER_FG_PAT)' {
        BeforeAll {
            Connect-GitHubAccount -Token $env:TEST_USER_USER_FG_PAT
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }

        It 'Get-GitHubEmoji - Gets a list of all emojis' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
        }
    }

    Context 'As a user - Fine-grained PAT token - organization account access (ORG_FG_PAT)' {
        BeforeAll {
            Connect-GitHubAccount -Token $env:TEST_USER_ORG_FG_PAT
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
        It 'Get-GitHubEmoji - Gets a list of all emojis' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
        }
    }

    Context 'As a user - Classic PAT token (PAT)' {
        BeforeAll {
            Connect-GitHubAccount -Token $env:TEST_USER_PAT
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
        It 'Get-GitHubEmoji - Gets a list of all emojis' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
        }

    }

    Context 'As GitHub Actions (GHA)' {
        BeforeAll {
            Connect-GitHubAccount
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
        It 'Get-GitHubEmoji - Gets a list of all emojis' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
        }

    }

    Context 'As a GitHub App - Enterprise (APP_ENT)' {
        BeforeAll {
            Connect-GitHubAccount -ClientID $env:TEST_APP_ENT_CLIENT_ID -PrivateKey $env:TEST_APP_ENT_PRIVATE_KEY
            Connect-GitHubApp -Organization 'psmodule-test-org3' -Default
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
        It 'Get-GitHubEmoji - Gets a list of all emojis' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
        }
    }

    Context 'As a GitHub App - Organization (APP_ORG)' {
        BeforeAll {
            Connect-GitHubAccount -ClientID $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
            Connect-GitHubApp -Organization 'psmodule-test-org' -Default
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
        It 'Get-GitHubEmoji - Gets a list of all emojis (APP_ORG)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (APP_ORG)' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
        }
    }
}
