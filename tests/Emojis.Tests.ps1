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

Describe 'Emojies' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
        }

        # Tests for APP goes here
        if ($AuthType -eq 'APP') {
            It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                LogGroup 'Context' {
                    Write-Host ($context | Format-List | Out-String)
                }
            }
        }

        # Tests for runners goes here
        if ($Type -eq 'GitHub Actions') {}

        # Tests for IAT UAT and PAT goes here
        It 'Get-GitHubEmoji - Gets a list of all emojis' {
            {
                $emojies = Get-GitHubEmoji
                LogGroup 'Emojies' {
                    Write-Host ($emojies | Format-Table | Out-String)
                }
            } | Should -Not -Throw
            $emojies| Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubEmoji - Downloads all emojis' {
            { Get-GitHubEmoji -Path $Home } | Should -Not -Throw
            LogGroup 'Emojies' {
                $emojies = Get-ChildItem -Path $Home -File
                Write-Host ($emojies | Format-Table | Out-String)
            }
            $emojies | Should -Not -BeNullOrEmpty
        }
    }
}

AfterAll {
    Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
}
