[CmdletBinding()]
Param(
    # Path to the module to test.
    [Parameter()]
    [string] $Path
)

Describe 'Get-GitHubStatus' {
    It 'Function exists' {
        Get-Command Get-GitHubStatus | Should -Not -BeNullOrEmpty
    }

    Context 'Parameter Set: Default' {
        It 'Can be called with no parameters' {
            { Get-GitHubStatus } | Should -Not -Throw
        }
    }

    Context 'Parameter Set: Summary' {
        It 'Can be called with Summary parameter' {
            { Get-GitHubStatus -Summary } | Should -Not -Throw
        }
    }
}
