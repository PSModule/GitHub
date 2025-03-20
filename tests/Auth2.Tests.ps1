#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'Used to create a secure string for testing.'
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
        if ($AuthType -eq 'APP') {
            It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                LogGroup 'Context' {
                    Write-Host ($context | Format-List | Out-String)
                }
                $context | Should -Not -BeNullOrEmpty
            }

            It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                $contexts = Connect-GitHubApp @connectAppParams -PassThru -Silent
                LogGroup 'Contexts' {
                    Write-Host ($contexts | Format-List | Out-String)
                }
                $contexts | Should -Not -BeNullOrEmpty
            }
        }

        It 'Get-GitHubViewer - Gets the logged in context' {
            $viewer = Get-GitHubViewer
            LogGroup 'Viewer' {
                Write-Host ($viewer | Format-List | Out-String)
            }
            $viewer | Should -Not -BeNullOrEmpty
        }

        It 'Disconnect-GitHubAccount - Disconnects all contexts' {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent -WarningAction SilentlyContinue
            (Get-GitHubContext -ListAvailable).count | Should -Be 0
        }
    }
}
