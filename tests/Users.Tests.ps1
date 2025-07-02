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

Describe 'Users' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            Write-Host ('-' * 60)
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

        # Tests for IAT UAT and PAT goes here
        It 'Get-GitHubUser - Get the specified user' {
            { Get-GitHubUser -Name 'Octocat' } | Should -Not -Throw
        }

        if ($OwnerType -eq 'user') {
            It 'Get-GitHubUser - Gets the authenticated user' {
                { Get-GitHubUser } | Should -Not -Throw
            }
            It 'Update-GitHubUser - Can set configuration on a user' {
                $guid = (New-Guid).Guid
                $user = Get-GitHubUser
                { Update-GitHubUser -DisplayName 'Octocat' } | Should -Not -Throw
                { Update-GitHubUser -Blog 'https://psmodule.io' } | Should -Not -Throw
                { Update-GitHubUser -TwitterUsername 'PSModule' } | Should -Not -Throw
                { Update-GitHubUser -Company 'PSModule' } | Should -Not -Throw
                { Update-GitHubUser -Location 'USA' } | Should -Not -Throw
                { Update-GitHubUser -Bio 'I love programming' } | Should -Not -Throw
                $tmpUser = Get-GitHubUser
                $tmpUser.DisplayName | Should -Be 'Octocat'
                $tmpUser.Blog | Should -Be 'https://psmodule.io'
                $tmpUser.TwitterUsername | Should -Be 'PSModule'
                $tmpUser.Company | Should -Be 'PSModule'
                $tmpUser.Location | Should -Be 'USA'
                $tmpUser.Bio | Should -Be 'I love programming'

                # Flaky tests
                # { Update-GitHubUser -Hireable $true } | Should -Not -Throw
                # $tmpUser.Hireable | Should -Be $true
            }
            Context 'Email' {
                It 'Get-GitHubUserEmail - Gets all email addresses for the authenticated user' {
                    { Get-GitHubUserEmail } | Should -Not -Throw
                }
                It 'Add/Remove-GitHubUserEmail - Adds and removes an email to the authenticated user' {
                    $email = (New-Guid).Guid + '@psmodule.io'
                    { Add-GitHubUserEmail -Email $email } | Should -Not -Throw
                    (Get-GitHubUserEmail).email | Should -Contain $email
                    { Remove-GitHubUserEmail -Email $email } | Should -Not -Throw
                    (Get-GitHubUserEmail).email | Should -Not -Contain $email
                }
            }
        }
    }
}
