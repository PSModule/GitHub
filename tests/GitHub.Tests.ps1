Describe 'GitHub' {
    Context 'Connect-GitHubAccount' {
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
            (Get-GitHubContext -ListAvailable).Count | Should -Be 4
        }

        # It 'Can be called with a GitHub App Installation Access Token' {
        #     { Connect-GitHubAccount -Token $env:TEST_APP_INSTALLATION_ACCESS_TOKEN } | Should -Not -Throw
        # }
    }



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
