[CmdletBinding()]
Param(
    # Path to the module to test.
    [Parameter()]
    [string] $Path
)

Write-Verbose "Path to the module: [$Path]" -Verbose

Describe 'Get-GitHubRateLimit' {
    It 'Function exists' {
        Get-Command Get-GitHubRateLimit | Should -Not -BeNullOrEmpty
    }

    It 'Can be called with no parameters' {
        { Get-GitHubRateLimit } | Should -Not -Throw
    }
}
