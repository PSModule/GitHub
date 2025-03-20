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
    $tests = . "$PSScriptRoot/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' {
        It 'Connect-GitHubAccount - Connects GitHub Actions without parameters' {
            $context = Connect-GitHubAccount @connectParams -PassThru
            $context | Should -Not -BeNullOrEmpty
        }
        if ($context.AuthType -eq 'APP') {
            It 'Connect-GitHubApp - Connects the app to <Owner>' {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default
                $context | Should -Not -BeNullOrEmpty
            }
        }
        It 'Get-GitHubViewer - Gets the logged in context' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }
    }

    AfterEach {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
}
