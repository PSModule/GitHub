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
            { Update-GitHubUser -TwitterUsername 'PSModule' } | Should -Not -Throw
            { Update-GitHubUser -Company 'PSModule' } | Should -Not -Throw
            { Update-GitHubUser -Location 'USA' } | Should -Not -Throw
            { Update-GitHubUser -Bio 'I love programming' } | Should -Not -Throw
            $tmpUser = Get-GitHubUser
            $tmpUser.name | Should -Be 'Octocat'
            $tmpUser.blog | Should -Be 'https://psmodule.io'
            $tmpUser.twitter_username | Should -Be 'PSModule'
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
                { Add-GitHubUserEmail -Email $email } | Should -Not -Throw
                (Get-GitHubUserEmail).email | Should -Contain $email
                { Remove-GitHubUserEmail -Email $email } | Should -Not -Throw
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
    Context 'User' {
        It 'Get-GitHubUser - Gets the authenticated user (ORG_FG_PAT)' {
            { Get-GitHubUser } | Should -Not -Throw
        }
        It 'Get-GitHubUser - Get the specified user (ORG_FG_PAT)' {
            { Get-GitHubUser -Username 'Octocat' } | Should -Not -Throw
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
            { Update-GitHubUser -TwitterUsername 'PSModule' } | Should -Not -Throw
            { Update-GitHubUser -Company 'PSModule' } | Should -Not -Throw
            { Update-GitHubUser -Location 'USA' } | Should -Not -Throw
            { Update-GitHubUser -Bio 'I love programming' } | Should -Not -Throw
            $tmpUser = Get-GitHubUser
            $tmpUser.name | Should -Be 'Octocat'
            $tmpUser.blog | Should -Be 'https://psmodule.io'
            $tmpUser.twitter_username | Should -Be 'PSModule'
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
                { Add-GitHubUserEmail -Email $email } | Should -Not -Throw
                (Get-GitHubUserEmail).email | Should -Contain $email
                { Remove-GitHubUserEmail -Email $email } | Should -Not -Throw
                (Get-GitHubUserEmail).email | Should -Not -Contain $email
            }
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
}

Describe 'As a GitHub App - Organization (APP_ORG)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
}
