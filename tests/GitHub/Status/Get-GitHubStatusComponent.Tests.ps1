[CmdletBinding()]
Param(
    # Path to the module to test.
    [Parameter()]
    [string] $Path
)

Describe 'Get-GitHubStatusComponent' {
    It 'Function exists' {
        Get-Command Get-GitHubStatusComponent | Should -Not -BeNullOrEmpty
    }

    It 'Can be called with no parameters' {
        { Get-GitHubStatusComponent } | Should -Not -Throw
    }
}
