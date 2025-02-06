#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[CmdletBinding()]
param()

Describe 'Auth' {
    BeforeAll {
        # Start fresh
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    AfterEach {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }

    Context 'GHA' {
        It 'GHA - Connect-GitHubAccount' {
            { Connect-GitHubAccount } | Should -Not -Throw
            $context = Get-GitHubContext

            $context.GetType().Name | Should -Be 'InstallationGitHubContext'
            $context.AuthType | Should -Be 'IAT'
            $context.Token | Should -Not -BeNullOrEmpty
        }

        It 'GHA - Get-GitHubViewer - Gets the logged in context' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
    }

    Context 'PAT' {
        It 'PAT - Connect-GitHubAccount' {
            { Connect-GitHubAccount -Token $env:TEST_USER_PAT } | Should -Not -Throw
            $context = Get-GitHubContext

            $context.GetType().Name | Should -Be 'UserGitHubContext'
            $context.AuthType | Should -Be 'PAT'
            $context.Token | Should -Not -BeNullOrEmpty
        }

        It 'PAT - Get-GitHubViewer - Gets the logged in context' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
    }

    Context 'USER_FG_PAT' {
        It 'USER_FG_PAT - Connect-GitHubAccount' {
            { Connect-GitHubAccount -Token $env:TEST_USER_USER_FG_PAT } | Should -Not -Throw
            $context = Get-GitHubContext

            $context.GetType().Name | Should -Be 'UserGitHubContext'
            $context.AuthType | Should -Be 'PAT'
            $context.Token | Should -Not -BeNullOrEmpty
        }

        It 'USER_FG_PAT - Get-GitHubViewer - Gets the logged in context' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
    }

    Context 'ORG_FG_PAT' {
        It 'ORG_FG_PAT - Connect-GitHubAccount' {
            { Connect-GitHubAccount -Token $env:TEST_USER_ORG_FG_PAT } | Should -Not -Throw
            $context = Get-GitHubContext

            $context.GetType().Name | Should -Be 'UserGitHubContext'
            $context.AuthType | Should -Be 'PAT'
            $context.Token | Should -Not -BeNullOrEmpty
        }

        It 'ORG_FG_PAT - Get-GitHubViewer - Gets the logged in context' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
    }

    Context 'APP_ENT' {
        It 'ORG_FG_PAT - Connect-GitHubAccount' {
            { Connect-GitHubAccount -ClientID $env:TEST_APP_ENT_CLIENT_ID -PrivateKey $env:TEST_APP_ENT_PRIVATE_KEY } | Should -Not -Throw
            $context = Get-GitHubContext

            $context.GetType().Name | Should -Be 'UserGitHubContext'
            $context.AuthType | Should -Be 'PAT'
            $context.Token | Should -Not -BeNullOrEmpty
        }

        It 'ORG_FG_PAT - Get-GitHubViewer - Gets the logged in context' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
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
