Describe 'Connect-GitHubAccount' {
    It 'Function exists' {
        Get-Command Connect-GitHubAccount | Should -Not -BeNullOrEmpty
    }

    Context 'Parameter Set: autologon IAT' {
        It 'Can be called with without parameters' {
            { Connect-GitHubAccount } | Should -Not -Throw
        }

        It 'Can be called with without parameters - a second time' {
            { Connect-GitHubAccount } | Should -Not -Throw
        }
    }
}
