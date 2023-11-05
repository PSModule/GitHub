Describe 'Connect-GitHubAccount' {
    It 'Function exists' {
        Get-Command Connect-GitHubAccount | Should -Not -BeNullOrEmpty
    }

    Context 'Parameter Set: DeviceFlow' {
        It 'Can be called with no parameters' {
            { Connect-GitHubAccount } | Should -Not -Throw
        }

        It 'Can be called with Mode parameter' {
            { Connect-GitHubAccount -Mode 'OAuthApp' } | Should -Not -Throw
        }

        It 'Can be called with Scope parameter' {
            { Connect-GitHubAccount -Scope 'gist read:org repo workflow' } | Should -Not -Throw
        }
    }

    Context 'Parameter Set: PAT' {
        It 'Can be called with AccessToken parameter' {
            { Connect-GitHubAccount -AccessToken } | Should -Not -Throw
        }
    }
}
