Describe 'Connect-GitHubAccount' {
    It 'Function exists' {
        Get-Command Connect-GitHubAccount | Should -Not -BeNullOrEmpty
    }

    Context 'Parameter Set: IAT' {
        It 'Can be called with GITHUB_TOKEN' {
            { Connect-GitHubAccount -Token $env:GITHUB_TOKEN } | Should -Not -Throw
        }

        It 'Can be called with GITHUB_TOKEN - a second time' {
            { Connect-GitHubAccount -Token $env:GITHUB_TOKEN } | Should -Not -Throw
        }
    }
}
