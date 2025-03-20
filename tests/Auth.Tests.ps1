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
    $authCases = . "$PSScriptRoot/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        It 'Connect-GitHubAccount - Connects using the provided credentials' {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
        }

        It 'Connect-GitHubAccount - Connects using the provided credentials - Double' {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            $context | Should -Not -BeNullOrEmpty
        }

        It 'Connect-GitHubAccount - Connects using the provided credentials - Relog' {
            Disconnect-GitHub -Silent
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
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

        if ($AuthType -eq 'APP') {
            It 'Connect-GitHubAccount - Connects using the provided credentials + AutoloadInstallations' {
                $context = Connect-GitHubAccount @connectParams -PassThru -Silent -AutoloadInstallations
                LogGroup 'Context' {
                    Write-Host ($context | Format-List | Out-String)
                }
                $context | Should -Not -BeNullOrEmpty
            }

            It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                $contexts = Connect-GitHubApp -PassThru -Silent
                LogGroup 'Contexts' {
                    Write-Host ($contexts | Format-List | Out-String)
                }
                $contexts | Should -Not -BeNullOrEmpty
            }

            It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                LogGroup 'Context' {
                    Write-Host ($context | Format-List | Out-String)
                }
                $context | Should -Not -BeNullOrEmpty
            }
        }

        It 'Connect-GitHubAccount - Connects to GitHub CLI on runners' {
            [string]::IsNullOrEmpty($(gh auth token)) | Should -Be $false
        }
        It 'Get-GitHubViewer - Gets the logged in context' {
            $viewer = Get-GitHubViewer
            LogGroup 'Viewer' {
                Write-Host ($viewer | Format-List | Out-String)
            }
            $viewer | Should -Not -BeNullOrEmpty
        }

        It 'GetGitHubContext - Gets the default context' {
            $context = Get-GitHubContext
            LogGroup 'Default context' {
                Write-Host ($viewer | Format-List | Out-String)
            }
        }

        It 'GetGitHubContext - List all contexts' {
            $contexts = Get-GitHubContext -ListAvailable
            LogGroup 'Contexts' {
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
