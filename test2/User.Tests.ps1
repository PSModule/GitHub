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

Context 'User' {
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
            { Get-GitHubUser -Username 'Octocat' } | Should -Not -Throw
        }

        if ($OwnerType -eq 'user') {
            It 'Get-GitHubUser - Gets the authenticated user' {
                { Get-GitHubUser } | Should -Not -Throw
            }
            It 'Update-GitHubUser - Can set configuration on a user' {
                $guid = (New-Guid).Guid
                $user = Get-GitHubUser
                { Update-GitHubUser -Name 'Octocat' } | Should -Not -Throw
                { Update-GitHubUser -Blog 'https://psmodule.io' } | Should -Not -Throw
                { Update-GitHubUser -TwitterUsername 'PSModule' } | Should -Not -Throw
                { Update-GitHubUser -Company 'PSModule' } | Should -Not -Throw
                { Update-GitHubUser -Location 'USA' } | Should -Not -Throw
                { Update-GitHubUser -Bio 'I love programming' } | Should -Not -Throw
                $tmpUser = Get-GitHubUser
                $tmpUser.name | Should -Be 'Octocat'
                $tmpUser.blog | Should -Be 'https://psmodule.io'
                $tmpUser.twitter_username | Should -Be 'PSModule'
                $tmpUser.company | Should -Be 'PSModule'
                $tmpUser.location | Should -Be 'USA'
                $tmpUser.bio | Should -Be 'I love programming'
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
