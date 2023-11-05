Describe 'Disconnect-GitHubAccount' {
    It 'Function exists' {
        Get-Command Disconnect-GitHubAccount | Should -Not -BeNullOrEmpty
    }

    It 'Can be called with no parameters' {
        { Disconnect-GitHubAccount } | Should -Not -Throw
    }
}
