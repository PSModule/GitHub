﻿Describe 'GitHub' {
    Context 'Auth' {
        It 'Can connect and disconnect without parameters in GitHubActions' {
            { Connect-GitHubAccount } | Should -Not -Throw
            { Disconnect-GitHubAccount } | Should -Not -Throw
        }

        It 'Can connect and disconnect - a second time' {
            { Connect-GitHubAccount } | Should -Not -Throw
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
            Write-Verbose (Get-GitHubConfig | Out-String) -Verbose
            { Connect-GitHubAccount } | Should -Not -Throw
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
            Write-Verbose (Get-GitHubConfig | Out-String) -Verbose
            { Disconnect-GitHubAccount } | Should -Not -Throw
        }

        It 'Can connect multiple sessions, GITHUB_TOKEN + classic PAT token' {
            { Connect-GitHubAccount -Token $env:TEST_PAT } | Should -Not -Throw
            { Connect-GitHubAccount } | Should -Not -Throw
            (Get-GitHubContext).Count | Should -Be 2
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/github-actions[bot]'
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
        }

        It 'Can reconfigure an existing context to be fine-grained PAT token' {
            { Connect-GitHubAccount -Token $env:TEST_FG_PAT } | Should -Not -Throw
            (Get-GitHubContext).Count | Should -Be 2
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
        }

        It 'Can be called with a GitHub App' {
            { Connect-GitHubAccount -ClientID $env:TEST_APP_CLIENT_ID -PrivateKey $env:TEST_APP_PRIVATE_KEY } | Should -Not -Throw
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
        }

        It 'Can list all contexts' {
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
            (Get-GitHubContext -ListAvailable).Count | Should -Be 3
        }

        It 'Can swap context to another' {
            { Set-GitHubDefaultContext -Context 'github.com/github-actions[bot]' } | Should -Not -Throw
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/github-actions[bot]'
        }

        # It 'Can be called with a GitHub App Installation Access Token' {
        #     { Connect-GitHubAccount -Token $env:TEST_APP_INSTALLATION_ACCESS_TOKEN } | Should -Not -Throw
        # }

        It 'Get-GitHubViewer can be called' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubConfig gets the DefaultContext' {
            Write-Verbose (Get-GitHubConfig -Name 'DefaultContext') -Verbose
            { Get-GitHubConfig -Name 'DefaultContext' } | Should -Not -Throw
        }
        It 'Can be called without a parameter' {
            $config = Get-GitHubConfig
            Write-Verbose ($config | Format-Table | Out-String) -Verbose
            { Get-GitHubConfig } | Should -Not -Throw
            $config.ContextID | Should -Be 'GitHub'
        }
    }
}

Context 'API' {
    It 'Can be called directly to get ratelimits' {
        {
            $rateLimit = Invoke-GitHubAPI -ApiEndpoint '/rate_limit'
            Write-Verbose ($rateLimit | Format-Table | Out-String) -Verbose
        } | Should -Not -Throw

    }
}

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
                Get-ChildItem env: | Select-Object Name, Value | Format-Table -AutoSize
            }
        } | Should -Not -Throw
    }
}
