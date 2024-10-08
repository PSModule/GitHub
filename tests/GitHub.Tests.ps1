﻿[CmdletBinding()]
Param(
    # Path to the module to test.
    [Parameter()]
    [string] $Path
)

Write-Verbose "Path to the module: [$Path]" -Verbose

BeforeAll {
    Connect-GitHub
}

Describe 'GitHub' {
    Context 'Invoke-GitHubAPI' {
        It 'Invoke-GitHubAPI function exists' {
            Get-Command Invoke-GitHubAPI | Should -Not -BeNullOrEmpty
        }

        It 'Can be called directly to get ratelimits' {
            { Invoke-GitHubAPI -ApiEndpoint '/rate_limit' -Method GET } | Should -Not -Throw
        }
    }
    Context 'Get-GitHubConfig' {
        It 'Get-GitHubConfig function exists' {
            Get-Command Get-GitHubConfig | Should -Not -BeNullOrEmpty
        }

        It 'Can be called directly to get the ApiBaseUri' {
            Write-Verbose (Get-GitHubConfig -Name ApiBaseUri) -Verbose
            { Get-GitHubConfig -Name ApiBaseUri } | Should -Not -Throw
        }
        It 'Can be called without a parameter' {
            $config = Get-GitHubConfig
            Write-Verbose ($config.Secrets | Format-List | Out-String) -Verbose
            Write-Verbose ($config.Variables | Format-List | Out-String) -Verbose
            { Get-GitHubConfig } | Should -Not -Throw
        }
    }
}
