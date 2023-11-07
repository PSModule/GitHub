Describe 'Connect-GitHubAccount' {
    It 'Function exists' {
        Get-Command Connect-GitHubAccount | Should -Not -BeNullOrEmpty
    }

    Context 'Parameter Set: sPAT' {
        It 'Can be called with no parameters' {
            { Connect-GitHubAccount } | Should -Not -Throw
        }
    }
}
