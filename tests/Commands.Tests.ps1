﻿[CmdletBinding()]
Param(
    # Path to the module to test.
    [Parameter()]
    [string] $Path
)

Write-Verbose "Path to the module: [$Path]" -Verbose

Describe 'Commands' {
    It "Start-LogGroup 'MyGroup' should not throw" {
        {
            Start-LogGroup 'MyGroup'
        } | Should -Not -Throw
    }

    It 'Stop-LogGroup should not throw' {
        {
            Stop-LogGroup
        } | Should -Not -Throw
    }

    It "LogGroup 'MyGroup' should not throw" {
        {
            LogGroup 'MyGroup' {
                Write-Host 'Hello, World!'
            }
        } | Should -Not -Throw
    }
}



