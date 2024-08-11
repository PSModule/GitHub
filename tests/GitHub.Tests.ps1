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
            $inputObject = @{
                APIEndpoint = '/rate_limit'
                Method      = 'GET'
            }
            
            try {
                $response = Invoke-GitHubAPI @inputObject
            } catch {
                Get-PSCallStack -Verbose
                Write-Verbose ($_.Exception.Message) -Verbose
            }

            $response | Should -Not -BeNullOrEmpty
            $response.Response.rate | Should -Not -BeNullOrEmpty
            $response.Response.resources.core | Should -Not -BeNullOrEmpty
        }
    }
}
