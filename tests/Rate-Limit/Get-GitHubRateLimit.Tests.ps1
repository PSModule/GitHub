﻿Describe 'Get-GitHubRateLimit' {
    It 'Function exists' {
        Get-Command Get-GitHubRateLimit | Should -Not -BeNullOrEmpty
    }

    It 'Can be called with no parameters' {
        Get-Command Invoke-RestMethod
        Get-Help Invoke-RestMethod -Full
        Get-GitHubRateLimit | Should -Not -Throw
    }
}
