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
    Context 'Emoji' {
        It 'Get-GitHubEmoji - Gets a list of all emojis (USER_FG_PAT)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (USER_FG_PAT)' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
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
    Context 'Emoji' {
        It 'Get-GitHubEmoji - Gets a list of all emojis (ORG_FG_PAT)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (ORG_FG_PAT)' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
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
    Context 'Emoji' {
        It 'Get-GitHubEmoji - Gets a list of all emojis (PAT)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (PAT)' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
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
    Context 'Emoji' {
        It 'Get-GitHubEmoji - Gets a list of all emojis (GHA)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (GHA)' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
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
    Context 'Emoji' {
        It 'Get-GitHubEmoji - Gets a list of all emojis (PAT)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (PAT)' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
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
    Context 'Emoji' {
        BeforeAll {
            Connect-GitHubApp -Organization 'psmodule-test-org' -Default
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
        It 'Get-GitHubEmoji - Gets a list of all emojis (PAT)' {
            { Get-GitHubEmoji } | Should -Not -Throw
        }
        It 'Get-GitHubEmoji - Downloads all emojis (PAT)' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
        }
    }
}
