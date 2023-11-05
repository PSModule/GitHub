Describe 'Get-GitHubRateLimit' {
    It 'Function exists' {
        Get-Command Get-GitHubRateLimit | Should -Not -BeNullOrEmpty
    }

    It 'Can be called with no parameters' {
        Write-Verbose (Get-Command Invoke-RestMethod | Out-String)
        Write-Verbose (Get-Help Invoke-RestMethod -Full | Out-String)
        Get-GitHubRateLimit | Should -Not -Throw
    }
}
