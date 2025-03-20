﻿#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

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
    Context 'Auth' {
        It 'Connect-GitHubAccount - Connects GitHub Actions without parameters' {
            { Connect-GitHubAccount } | Should -Not -Throw
            [string]::IsNullOrEmpty($(gh auth token)) | Should -Be $false
        }
        It 'Disconnect-GitHubAccount - Disconnects GitHub Actions' {
            { Disconnect-GitHubAccount } | Should -Not -Throw
        }
        It 'Connect-GitHubAccount - Passes the context to the pipeline' {
            $context = Connect-GitHubAccount -PassThru
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
            $context | Should -Not -BeNullOrEmpty
        }
        It 'Connect-GitHubAccount - Connects with default settings' {
            $context = Get-GitHubContext
            Write-Verbose ($context | Select-Object -Property * | Out-String) -Verbose
            $context | Should -Not -BeNullOrEmpty
            $context.ApiBaseUri | Should -Be 'https://api.github.com'
            $context.ApiVersion | Should -Be '2022-11-28'
            $context.AuthType | Should -Be 'IAT'
            $context.HostName | Should -Be 'github.com'
            $context.HttpVersion | Should -Be '2.0'
            $context.TokenType | Should -Be 'ghs'
            $context.Name | Should -Be 'github.com/github-actions/Organization/PSModule'
        }
        It 'Disconnect-GitHubAccount - Disconnects the context from the pipeline' {
            $context = Get-GitHubContext
            { $context | Disconnect-GitHubAccount } | Should -Not -Throw
        }
        It 'Connect-GitHubAccount - Connects GitHub Actions even if called multiple times' {
            { Connect-GitHubAccount } | Should -Not -Throw
            { Connect-GitHubAccount } | Should -Not -Throw
        }
        It 'Connect-GitHubAccount - Connects multiple contexts, GitHub Actions and a user via classic PAT token' {
            { Connect-GitHubAccount -Token $env:TEST_USER_PAT } | Should -Not -Throw
            { Connect-GitHubAccount -Token $env:TEST_USER_PAT } | Should -Not -Throw
            { Connect-GitHubAccount } | Should -Not -Throw
            (Get-GitHubContext -ListAvailable).Count | Should -Be 2
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/github-actions/Organization/PSModule'
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
        }
        It 'Connect-GitHubAccount - Reconfigures an existing user context to be a fine-grained PAT token' {
            { Connect-GitHubAccount -Token $env:TEST_USER_USER_FG_PAT } | Should -Not -Throw
            (Get-GitHubContext -ListAvailable).Count | Should -Be 2
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
        }
        It 'Connect-GitHubAccount - Connects a GitHub App from an organization' {
            $params = @{
                ClientID   = $env:TEST_APP_ORG_CLIENT_ID
                PrivateKey = $env:TEST_APP_ORG_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params } | Should -Not -Throw
            $contexts = Get-GitHubContext -ListAvailable -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 3
        }
        It 'Connect-GitHubAccount - Connects all of a (org) GitHub Apps installations' {
            $params = @{
                ClientID   = $env:TEST_APP_ORG_CLIENT_ID
                PrivateKey = $env:TEST_APP_ORG_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params -AutoloadInstallations } | Should -Not -Throw
            $contexts = Get-GitHubContext -ListAvailable -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 5
        }
        It 'Connect-GitHubAccount - Connects a GitHub App from an enterprise' {
            $params = @{
                ClientID   = $env:TEST_APP_ENT_CLIENT_ID
                PrivateKey = $env:TEST_APP_ENT_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params } | Should -Not -Throw
            $contexts = Get-GitHubContext -ListAvailable -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 6
        }
        It 'Connect-GitHubAccount - Connects all of a (ent) GitHub Apps installations' {
            $params = @{
                ClientID   = $env:TEST_APP_ENT_CLIENT_ID
                PrivateKey = $env:TEST_APP_ENT_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params -AutoloadInstallations } | Should -Not -Throw
            $contexts = Get-GitHubContext -ListAvailable -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 8
        }
        It 'Disconnect-GitHubAccount - Disconnects a specific context' {
            { Disconnect-GitHubAccount -Context 'github.com/psmodule-enterprise-app/Enterprise/msx' -Silent } | Should -Not -Throw
            $contexts = Get-GitHubContext -Context 'github.com/psmodule-enterprise-app/*' -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 1
        }
    }
    Context 'DefaultContext' {
        BeforeAll {
            Connect-GitHub
        }
        It 'Set-GitHubDefaultContext - Can swap context to another' {
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
            { Set-GitHubDefaultContext -Context 'github.com/github-actions/Organization/PSModule' } | Should -Not -Throw
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/github-actions/Organization/PSModule'
        }

        It 'Set-GitHubDefaultContext - Can swap context to another using pipeline - String' {
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
            { 'github.com/psmodule-user' | Set-GitHubDefaultContext } | Should -Not -Throw
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/psmodule-user'
        }

        It 'Set-GitHubDefaultContext - Can swap context to another using pipeline - Context object' {
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
            { Get-GitHubContext -Context 'github.com/psmodule-org-app' | Set-GitHubDefaultContext } | Should -Not -Throw
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/psmodule-org-app'
        }
    }
    Context 'Disconnect' {
        It 'Disconnect-GitHubAccount - Can disconnect all context through the pipeline' {
            { Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount } | Should -Not -Throw
            Get-GitHubContext -ListAvailable | Should -HaveCount 0
        }
    }
}
