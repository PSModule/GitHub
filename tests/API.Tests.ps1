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

BeforeAll {
    # DEFAULTS ACCROSS ALL TESTS
}

Describe 'Template' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }

        # Tests for APP goes here
        if ($AuthType -eq 'APP') {
            It 'Invoke-GitHubAPI - Gets the app details' {
                {
                    $app = Invoke-GitHubAPI -ApiEndpoint '/app'
                    LogGroup 'App' {
                        Write-Host ($app | Format-Table | Out-String)
                    }
                } | Should -Not -Throw
            }

            It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                LogGroup 'Context' {
                    Write-Host ($context | Format-List | Out-String)
                }
                $context | Should -Not -BeNullOrEmpty
            }
        }

        # Tests for runners goes here
        if ($Type -eq 'GitHub Actions') {}

        # Tests for IAT UAT and PAT goes here
        Context 'API' {
            It 'Invoke-GitHubAPI - Gets the rate limits directly using APIEndpoint' {
                {
                    $rateLimit = Invoke-GitHubAPI -ApiEndpoint '/rate_limit'
                    LogGroup 'RateLimit' {
                        Write-Host ($rateLimit | Format-Table | Out-String)
                    }
                } | Should -Not -Throw
            }

            It 'Invoke-GitHubAPI - Gets the rate limits directly using Uri' {
                {
                    $rateLimit = Invoke-GitHubAPI -Uri ($context.ApiBaseUri + '/rate_limit')
                    LogGroup 'RateLimit' {
                        Write-Host ($rateLimit | Format-Table | Out-String)
                    }
                } | Should -Not -Throw
            }

            It 'Invoke-GitHubGraphQLQuery - Gets the viewer' {
                {
                    $viewer = Invoke-GitHubGraphQLQuery -Query 'query { viewer { login } }'
                    LogGroup 'Viewer' {
                        Write-Host ($viewer | Format-Table | Out-String)
                    }
                } | Should -Not -Throw
            }
        }

        Context 'Meta' {
            It 'Get-GitHubRoot - Gets the GitHub API Root' {
                $root = Get-GitHubRoot
                LogGroup 'Root' {
                    Write-Host ($root | Format-Table | Out-String)
                }
                $root | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubApiVersion - Gets all API versions' {
                $apiVersion = Get-GitHubApiVersion
                LogGroup 'ApiVersion' {
                    Write-Host ($apiVersion | Format-Table | Out-String)
                }
                $apiVersion | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubMeta - Gets GitHub meta information' {
                $meta = Get-GitHubMeta
                LogGroup 'Meta' {
                    Write-Host ($meta | Format-Table | Out-String)
                }
                $meta | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubOctocat - Gets the Octocat' {
                $octocat = Get-GitHubOctocat
                LogGroup 'Octocat' {
                    Write-Host ($octocat | Format-Table | Out-String)
                }
                $octocat | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubZen - Gets the Zen of GitHub' {
                $zen = Get-GitHubZen
                LogGroup 'Zen' {
                    Write-Host ($zen | Format-Table | Out-String)
                }
                $zen | Should -Not -BeNullOrEmpty
            }
        }

        Context 'Rate-Limit' {
            It 'Get-GitHubRateLimit - Gets the rate limit status for the authenticated user' {
                $rateLimit = Get-GitHubRateLimit
                LogGroup 'RateLimit' {
                    Write-Host ($rateLimit | Format-Table | Out-String)
                }
                $rateLimit | Should -Not -BeNullOrEmpty
            }
        }

        Context 'License' {
            It 'Get-GitHubLicense - Gets a list of all popular license templates' {
                $licenseList = Get-GitHubLicense
                LogGroup 'Licenses' {
                    Write-Host ($licenseList | Format-Table | Out-String)
                }
                $licenseList | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubLicense - Gets a spesific license' {
                $mitLicense = Get-GitHubLicense -Name 'mit'
                LogGroup 'MIT License' {
                    Write-Host ($mitLicense | Format-Table | Out-String)
                }
                $mitLicense | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubLicense - Gets a license from a repository' {
                $githubLicense = Get-GitHubLicense -Owner 'PSModule' -Repository 'GitHub'
                LogGroup 'GitHub License' {
                    Write-Host ($githubLicense | Format-Table | Out-String)
                }
                $githubLicense | Should -Not -BeNullOrEmpty
            }
        }

        Context 'GitIgnore' {
            It 'Get-GitHubGitignore - Gets a list of all gitignore templates names' {
                $gitIgnoreList = Get-GitHubGitignore
                LogGroup 'GitIgnoreList' {
                    Write-Host ($gitIgnoreList | Format-Table | Out-String)
                }
                $gitIgnoreList | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubGitignore - Gets a gitignore template' {
                $vsGitIgnore = Get-GitHubGitignore -Name 'VisualStudio'
                LogGroup 'Visual Studio GitIgnore' {
                    Write-Host ($vsGitIgnore | Format-Table | Out-String)
                }
                $vsGitIgnore | Should -Not -BeNullOrEmpty
            }
        }

        Context 'Markdown' {
            It 'Get-GitHubMarkdown - Gets the rendered markdown for provided text' {
                $markdown = Get-GitHubMarkdown -Text 'Hello, World!'
                LogGroup 'Markdown' {
                    Write-Host ($markdown | Format-Table | Out-String)
                }
                $markdown | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubMarkdown - Gets the rendered markdown for provided text using GitHub Formated Markdown' {
                $gfmMarkdown = Get-GitHubMarkdown -Text 'Hello, World!' -Mode gfm
                LogGroup 'GFM Markdown' {
                    Write-Host ($gfmMarkdown | Format-Table | Out-String)
                }
                $gfmMarkdown | Should -Not -BeNullOrEmpty
            }
            It 'Get-GitHubMarkdownRaw - Gets the raw rendered markdown for provided text' {
                $rawMarkdown = Get-GitHubMarkdownRaw -Text 'Hello, World!'
                LogGroup 'Raw Markdown' {
                    Write-Host ($rawMarkdown | Format-Table | Out-String)
                }
                $rawMarkdown | Should -Not -BeNullOrEmpty
            }
        }

        Context 'Git' {
            It "Get-GitHubGitConfig gets the 'local' (default) Git configuration" {
                $gitConfig = Get-GitHubGitConfig
                LogGroup 'GitConfig' {
                    Write-Host ($gitConfig | Format-List | Out-String)
                }
                $gitConfig | Should -Not -BeNullOrEmpty
            }
            It "Get-GitHubGitConfig gets the 'global' Git configuration" {
                git config --global advice.pushfetchfirst false
                $gitConfig = Get-GitHubGitConfig -Scope 'global'
                LogGroup 'GitConfig - Global' {
                    Write-Host ($gitConfig | Format-List | Out-String)
                }
                $gitConfig | Should -Not -BeNullOrEmpty
            }
            It "Get-GitHubGitConfig gets the 'system' Git configuration" {
                $gitConfig = Get-GitHubGitConfig -Scope 'system'
                LogGroup 'GitConfig - System' {
                    Write-Host ($gitConfig | Format-List | Out-String)
                }
                $gitConfig | Should -Not -BeNullOrEmpty
            }
            It 'Set-GitHubGitConfig sets the Git configuration' {
                { Set-GitHubGitConfig } | Should -Not -Throw
                $gitConfig = Get-GitHubGitConfig -Scope 'global'
                LogGroup 'GitConfig - Global' {
                    Write-Host ($gitConfig | Format-List | Out-String)
                }
                $gitConfig | Should -Not -BeNullOrEmpty
                $gitConfig.'user.name' | Should -Not -BeNullOrEmpty
                $gitConfig.'user.email' | Should -Not -BeNullOrEmpty
            }
        }
    }
}

AfterAll {
    Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
}
