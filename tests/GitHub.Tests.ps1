Describe 'GitHub' {
    Context 'Auth' {
        It 'Connect-GitHubAccount function exists' {
            Get-Command Connect-GitHubAccount | Should -Not -BeNullOrEmpty
        }

        It 'Can be called without parameters on GitHub Actions' {
            { Connect-GitHubAccount } | Should -Not -Throw
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
        }

        It 'Can be called with a classic PAT token' {
            { Connect-GitHubAccount -Token $env:TEST_PAT } | Should -Not -Throw
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
        }

        It 'Can be called with a fine-grained PAT token' {
            { Connect-GitHubAccount -Token $env:TEST_FG_PAT } | Should -Not -Throw
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
    }

    Context 'Config' {
        It 'Get-GitHubConfig function exists' {
            Get-Command Get-GitHubConfig | Should -Not -BeNullOrEmpty
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

    Context 'API' {
        It 'Invoke-GitHubAPI function exists' {
            Get-Command Invoke-GitHubAPI | Should -Not -BeNullOrEmpty
        }

        It 'Can be called directly to get ratelimits' {
            { Invoke-GitHubAPI -ApiEndpoint '/rate_limit' -Method GET } | Should -Not -Throw
        }
    }

    Context 'Get-GitHubViewer' {
        It 'Get-GitHubViewer function exists' {
            Get-Command Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
        It 'Get-GiTubViewer can be called' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
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
