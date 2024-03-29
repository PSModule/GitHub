[CmdletBinding()]
Param(
    # Path to the module to test.
    [Parameter()]
    [string] $Path
)

Write-Verbose "Path to the module: [$Path]" -Verbose

Describe 'Get-GitHubStatusIncident' {
    It 'Function exists' {
        Get-Command Get-GitHubStatusIncident | Should -Not -BeNullOrEmpty
    }

    Context 'Parameter Set: Default' {
        It 'Can be called with no parameters' {
            { Get-GitHubStatusIncident } | Should -Not -Throw
        }
    }

    Context 'Parameter Set: Unresolved' {
        It 'Can be called with Unresolved parameter' {
            { Get-GitHubStatusIncident -Unresolved } | Should -Not -Throw
        }
    }
}
