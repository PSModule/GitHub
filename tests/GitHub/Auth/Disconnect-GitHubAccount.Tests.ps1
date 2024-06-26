﻿[CmdletBinding()]
Param(
    # Path to the module to test.
    [Parameter()]
    [string] $Path
)

Write-Verbose "Path to the module: [$Path]" -Verbose

Describe 'Disconnect-GitHubAccount' {
    It 'Function exists' {
        Get-Command Disconnect-GitHubAccount | Should -Not -BeNullOrEmpty
    }

    It 'Can be called with no parameters' {
        { Disconnect-GitHubAccount } | Should -Not -Throw
    }

    It 'Can reconnect after disconnecting' {
        { Connect-GitHubAccount } | Should -Not -Throw
    }
}
