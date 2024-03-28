[CmdletBinding()]
Param(
    # Path to the module to test.
    [Parameter()]
    [string] $Path
)

Describe 'Get-GitHubRateLimit' {
    It 'Function exists' {
        Get-Command Get-GitHubRateLimit | Should -Not -BeNullOrEmpty
    }

    It 'Can be called with no parameters' {
        { Get-GitHubRateLimit } | Should -Not -Throw
    }
}
