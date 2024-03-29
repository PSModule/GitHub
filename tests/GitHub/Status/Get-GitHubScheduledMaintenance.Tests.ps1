[CmdletBinding()]
Param(
    # Path to the module to test.
    [Parameter()]
    [string] $Path
)

Write-Verbose "Path to the module: [$Path]" -Verbose

Describe 'Get-GitHubScheduledMaintenance' {
    It 'Function exists' {
        Get-Command Get-GitHubScheduledMaintenance | Should -Not -BeNullOrEmpty
    }

    Context 'Parameter Set: Default' {
        It 'Can be called with no parameters' {
            { Get-GitHubScheduledMaintenance } | Should -Not -Throw
        }
    }

    Context 'Parameter Set: Active' {
        It 'Can be called with Active parameter' {
            { Get-GitHubScheduledMaintenance -Active } | Should -Not -Throw
        }
    }

    Context 'Parameter Set: Upcoming' {
        It 'Can be called with Upcoming parameter' {
            { Get-GitHubScheduledMaintenance -Upcoming } | Should -Not -Throw
        }
    }
}
