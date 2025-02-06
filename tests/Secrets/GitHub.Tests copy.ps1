#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[CmdletBinding()]
param()

Describe 'Auth' {
    AfterEach {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }

    Context 'As GitHub Actions (GHA)' {
        BeforeAll {
            Connect-GitHubAccount
        }

        It 'Get-GitHubViewer - Gets the logged in context (GHA)' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
    }

    Context 'PAT' {
        BeforeAll {
            Connect-GitHubAccount -Token $env:TEST_USER_PAT
        }

        It 'Get-GitHubViewer - Gets the logged in context (PAT)' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
    }

    Context 'USER_FG_PAT' {
        BeforeAll {
            Connect-GitHubAccount -Token $env:TEST_USER_USER_FG_PAT
        }

        It 'Get-GitHubViewer - Gets the logged in context (USER_FG_PAT)' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }


    }

    Context 'ORG_FG_PAT' {
        BeforeAll {
            Connect-GitHubAccount -Token $env:TEST_USER_ORG_FG_PAT
        }

        It 'Get-GitHubViewer - Gets the logged in context (ORG_FG_PAT)' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
    }

    Context 'APP_ENT' {
        BeforeAll {
            Connect-GitHubAccount -ClientID $env:TEST_APP_ENT_CLIENT_ID -PrivateKey $env:TEST_APP_ENT_PRIVATE_KEY
        }

        # Enterprise installations are not available for GitHub Apps yet.
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

    Context 'APP_ORG' {
        BeforeAll {
            Connect-GitHubAccount -ClientID $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
        }
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
}
