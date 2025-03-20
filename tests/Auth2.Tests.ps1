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
            $context = Connect-GitHubAccount @connectParams -PassThru
            Write-Host ($context | Format-List | Out-String)
            $context | Should -Not -BeNullOrEmpty
        }
        if ($AuthType -eq 'APP') {
            It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default
                Write-Host ($context | Format-List | Out-String)
                $context | Should -Not -BeNullOrEmpty
            }
        }

        It 'Get-GitHubViewer - Gets the logged in context' {
            Get-GitHubViewer | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubContext - Gets the logged in context' {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
    }
}
