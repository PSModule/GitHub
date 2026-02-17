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
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidLongLines', '',
    Justification = 'Long test descriptions and skip switches'
)]
[CmdletBinding()]
param()

Describe 'Emojis' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            if ($AuthType -eq 'APP') {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                LogGroup 'Context' {
                    Write-Host ($context | Format-List | Out-String)
                }
            }
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            Write-Host ('-' * 60)
        }

        It 'Get-GitHubEmoji - Gets a list of all emojis' {
            $emojis = Get-GitHubEmoji
            LogGroup 'emojis' {
                Write-Host ($emojis | Format-Table | Out-String)
            }
            $emojis | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubEmoji - Downloads all emojis' {
            Get-GitHubEmoji -Path $Home
            LogGroup 'emojis' {
                $emojis = Get-ChildItem -Path $Home -File
                Write-Host ($emojis | Format-Table | Out-String)
            }
            $emojis | Should -Not -BeNullOrEmpty
        }
    }
}
