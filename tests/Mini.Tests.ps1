#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'Used to create a secure string for testing.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', '',
    Justification = 'Log outputs to GitHub Actions logs.'
)]
[CmdletBinding()]
param()

Describe 'Auth' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }

        It 'Connect-GitHubAccount - Connects using the provided credentials' {
            LogGroup 'Context' {
                $context = Connect-GitHubAccount @connectParams -PassThru -Silent -Verbose -Debug
                Write-Host ($context | Format-List | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
        }

        It 'Connect-GitHubAccount - Connects using the provided credentials - Double' {
            LogGroup 'Context' {
                $context = Connect-GitHubAccount @connectParams -PassThru -Silent
                $context = Connect-GitHubAccount @connectParams -PassThru -Silent
                Write-Host ($context | Format-List | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
        }

        It 'Connect-GitHubAccount - Connects using the provided credentials - Relog' {
            LogGroup 'Context' {
                Disconnect-GitHub -Silent
                $context = Connect-GitHubAccount @connectParams -PassThru -Silent
                Write-Host ($context | Format-List | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
        }

        It 'Switch-GitHubContext - Sets the default context' {
            $context = Get-GitHubContext
            Switch-GitHubContext -Context $context
            $context = Get-GitHubContext
            $context | Should -Not -BeNullOrEmpty
        }

        # Tests for APP goes here
        if ($AuthType -eq 'APP') {
            It 'Connect-GitHubAccount - Connects using the provided credentials + AutoloadInstallations' {
                LogGroup 'Context' {
                    $context = Connect-GitHubAccount @connectParams -PassThru -Silent -AutoloadInstallations
                    Write-Host ($context | Format-List | Out-String)
                }
                $context | Should -Not -BeNullOrEmpty
            }

            It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                LogGroup 'Contexts' {
                    $contexts = Connect-GitHubApp -PassThru -Silent
                    Write-Host ($contexts | Format-List | Out-String)
                }
                $contexts | Should -Not -BeNullOrEmpty
            }

            It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                LogGroup 'Context' {
                    $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                    Write-Host ($context | Format-List | Out-String)
                }
                $context | Should -Not -BeNullOrEmpty
            }
        }

        # Tests for runners goes here
        if ($Type -eq 'GitHub Actions') {}

        # Tests for IAT UAT and PAT goes here
        It 'Connect-GitHubAccount - Connects to GitHub CLI on runners' {
            [string]::IsNullOrEmpty($(gh auth token)) | Should -Be $false
        }
        It 'Get-GitHubViewer - Gets the logged in context' {
            LogGroup 'Viewer' {
                $viewer = Get-GitHubViewer
                Write-Host ($viewer | Format-List | Out-String)
            }
            $viewer | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubContext - Gets the default context' {
            LogGroup 'Default context' {
                $context = Get-GitHubContext
                Write-Host ($viewer | Format-List | Out-String)
            }
        }

        It 'Get-GitHubContext - List all contexts' {
            LogGroup 'Contexts' {
                $contexts = Get-GitHubContext -ListAvailable
                Write-Host ($contexts | Format-List | Out-String)
            }
            $contexts.count | Should -BeGreaterOrEqual 1
        }

        It 'Disconnect-GitHubAccount - Disconnects all contexts' {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            (Get-GitHubContext -ListAvailable).count | Should -Be 0
        }
    }
}

Describe 'Anonymous - Functions that can run anonymously' {
    It 'Get-GithubRateLimit' {
        $rateLimit = Get-GitHubRateLimit -Anonymous
        LogGroup 'Rate Limit' {
            Write-Host ($rateLimit | Format-List | Out-String)
        }
        $rateLimit | Should -Not -BeNullOrEmpty
    }
    It 'Get-GithubMeta' {
        $meta = Get-GitHubMeta -Anonymous
        LogGroup 'Meta' {
            Write-Host ($meta | Format-List | Out-String)
        }
        $meta | Should -Not -BeNullOrEmpty
    }
    It 'Get-GithubOctocat' {
        $octocat = Get-GitHubOctocat -Anonymous
        LogGroup 'Octocat' {
            Write-Host ($octocat | Format-List | Out-String)
        }
        $octocat | Should -Not -BeNullOrEmpty
    }
    It 'Get-GithubZen' {
        $zen = Get-GitHubZen -Anonymous
        LogGroup 'Zen' {
            Write-Host ($zen | Format-List | Out-String)
        }
        $zen | Should -Not -BeNullOrEmpty
    }
    It 'Get-GithubGitignore' {
        $gitIgnore = Get-GitHubGitignore -Anonymous
        LogGroup 'GitIgnore' {
            Write-Host ($gitIgnore | Format-List | Out-String)
        }
        $gitIgnore | Should -Not -BeNullOrEmpty
    }
    It 'Get-GithubLicense' {
        $license = Get-GitHubLicense -Anonymous
        LogGroup 'License' {
            Write-Host ($license | Format-List | Out-String)
        }
        $license | Should -Not -BeNullOrEmpty
    }
}
