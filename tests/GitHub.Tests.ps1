[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
)]
[CmdletBinding()]
param()

BeforeAll {
    Get-SecretInfo | Remove-Secret
    Get-SecretVault | Unregister-SecretVault
}

Describe 'GitHub' {
    Context 'Config' {
        It 'Can get the configuration' {
            $config = Get-GitHubConfig
            Write-Verbose ($config | Format-Table | Out-String) -Verbose
            $config | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Auth' {
        It 'Can connect and disconnect without parameters in GitHubActions' {
            { Connect-GitHubAccount } | Should -Not -Throw
            { Disconnect-GitHubAccount } | Should -Not -Throw
        }

        It 'Can connect and disconnect - a second time' {
            Connect-GitHubAccount
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
            Write-Verbose (Get-GitHubConfig | Out-String) -Verbose
            Connect-GitHubAccount
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
            Write-Verbose (Get-GitHubConfig | Out-String) -Verbose
            { Disconnect-GitHubAccount } | Should -Not -Throw
        }

        It 'Can connect multiple sessions, GITHUB_TOKEN + classic PAT token' {
            { Connect-GitHubAccount -Token $env:TEST_PAT } | Should -Not -Throw
            { Connect-GitHubAccount -Token $env:TEST_PAT } | Should -Not -Throw
            { Connect-GitHubAccount } | Should -Not -Throw # Logs on with GitHub Actions' token
            (Get-GitHubContext -ListAvailable).Count | Should -Be 2
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/github-actions/Organization/PSModule'
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
        }

        It 'Can reconfigure an existing context to be fine-grained PAT token' {
            { Connect-GitHubAccount -Token $env:TEST_FG_PAT } | Should -Not -Throw
            (Get-GitHubContext -ListAvailable).Count | Should -Be 2
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
        }

        It 'Can be called with a GitHub App' {
            $params = @{
                ClientID   = $env:TEST_APP_CLIENT_ID
                PrivateKey = $env:TEST_APP_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params } | Should -Not -Throw
            $contexts = Get-GitHubContext -ListAvailable -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 3
        }
        It 'Can be called with a GitHub App and autoload installations' {
            $params = @{
                ClientID   = $env:TEST_APP_CLIENT_ID
                PrivateKey = $env:TEST_APP_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params -AutoloadInstallations } | Should -Not -Throw
            $contexts = Get-GitHubContext -ListAvailable -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 7
        }

        It 'Can disconnect a specific context' {
            { Disconnect-GitHubAccount -Context 'github.com/github-actions/Organization/PSModule' -Silent } | Should -Not -Throw
            $contexts = Get-GitHubContext -ListAvailable -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 6
            Connect-GitHubAccount -ClientID $env:TEST_APP_CLIENT_ID -PrivateKey $env:TEST_APP_PRIVATE_KEY -AutoloadInstallations
            $contexts = Get-GitHubContext -ListAvailable -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 7
        }

        It 'Can get the authenticated GitHubApp' {
            $app = Get-GitHubApp
            Write-Verbose ($app | Format-Table | Out-String) -Verbose
            $app | Should -Not -BeNullOrEmpty
        }

        It 'Can connect to a GitHub App Installation' {
            { Connect-GitHubApp -Organization 'PSModule' } | Should -Not -Throw
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
        }

        It 'Can connect to all GitHub App Installations' {
            { Connect-GitHubApp } | Should -Not -Throw
            Write-Verbose 'Default context:' -Verbose
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
            Write-Verbose 'All contexts:' -Verbose
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
        }

        It 'Can swap context to another' {
            { Set-GitHubDefaultContext -Context 'github.com/github-actions/Organization/PSModule' } | Should -Not -Throw
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/github-actions/Organization/PSModule'
        }

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
            $config.ID | Should -Be 'PSModule.GitHub'
        }
    }
    Context 'Meta' {
        It 'Get-GitHubRoot' {
            $root = Get-GitHubRoot
            Write-Verbose ($root | Format-Table | Out-String) -Verbose
            $root | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubApiVersion' {
            $apiVersion = Get-GitHubApiVersion
            Write-Verbose ($apiVersion | Format-Table | Out-String) -Verbose
            $apiVersion | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubMeta' {
            $meta = Get-GitHubMeta
            Write-Verbose ($meta | Format-Table | Out-String) -Verbose
            $meta | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubOctocat' {
            $octocat = Get-GitHubOctocat
            Write-Verbose ($octocat | Format-Table | Out-String) -Verbose
            $octocat | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubZen' {
            $zen = Get-GitHubZen
            Write-Verbose ($zen | Format-Table | Out-String) -Verbose
            $zen | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Git' {
        It 'Set-GitHubGitConfig sets the Git configuration' {
            { Set-GitHubGitConfig } | Should -Not -Throw
            $gitConfig = Get-GitHubGitConfig
            Write-Verbose ($gitConfig | Format-Table | Out-String) -Verbose

            $gitConfig | Should -Not -BeNullOrEmpty
            $gitConfig.'user.name' | Should -Not -BeNullOrEmpty
            $gitConfig.'user.email' | Should -Not -BeNullOrEmpty
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
}
