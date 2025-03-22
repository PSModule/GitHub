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

Describe 'Organizations' {
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

        # Tests for runners goes here
        if ($Type -eq 'GitHub Actions') {}

        It "Get-GitHubOrganization - Gets a specific organization 'PSModule'" {
            $organization = Get-GitHubOrganization -Organization 'PSModule'
            LogGroup 'Organization' {
                Write-Host ($organization | Format-Table | Out-String)
            }
            $organization | Should -Not -BeNullOrEmpty
        }
        It "Get-GitHubOrganization - List public organizations for the user 'psmodule-user'" {
            $organizations = Get-GitHubOrganization -Username 'psmodule-user'
            LogGroup 'Organization' {
                Write-Host ($organizations | Format-Table | Out-String)
            }
            $organizations | Should -Not -BeNullOrEmpty
        }

        # Tests for IAT UAT and PAT goes here
        if ($OwnerType -eq 'user') {
            It 'Get-GitHubOrganization - Gets the organizations for the authenticated user' {
                { Get-GitHubOrganization } | Should -Not -Throw
            }
        }

        if ($OwnerType -eq 'organization') {
            It 'Update-GitHubOrganization - Sets the organization configuration' {
                { Update-GitHubOrganization -Organization $owner -Company 'ABC' } | Should -Not -Throw
                {
                    $email = (New-Guid).Guid + '@psmodule.io'
                    Update-GitHubOrganization -Organization $owner -BillingEmail $email
                } | Should -Not -Throw
                {
                    $email = (New-Guid).Guid + '@psmodule.io'
                    Update-GitHubOrganization -Organization $owner -Email $email
                } | Should -Not -Throw
                { Update-GitHubOrganization -Organization $owner -TwitterUsername 'PSModule' } | Should -Not -Throw
                { Update-GitHubOrganization -Organization $owner -Location 'USA' } | Should -Not -Throw
                { Update-GitHubOrganization -Organization $owner -Description 'Test Organization' } | Should -Not -Throw
                { Update-GitHubOrganization -Organization $owner -DefaultRepositoryPermission read } | Should -Not -Throw
                { Update-GitHubOrganization -Organization $owner -MembersCanCreateRepositories $true } | Should -Not -Throw
                { Update-GitHubOrganization -Organization $owner -Blog 'https://psmodule.io' } | Should -Not -Throw
            }
        }

        # Context 'Invitations' {
        #     It 'New-GitHubOrganizationInvitation - Invites a user to an organization' {
        #         {
        #             $email = (New-Guid).Guid + '@psmodule.io'
        #             New-GitHubOrganizationInvitation -Organization $owner -Email $email -Role 'admin'
        #         } | Should -Not -Throw
        #     }
        #     It 'Get-GitHubOrganizationPendingInvitation - Gets the pending invitations for a specific organization' {
        #         { Get-GitHubOrganizationPendingInvitation -Organization $owner } | Should -Not -Throw
        #         { Get-GitHubOrganizationPendingInvitation -Organization $owner -Role 'admin' } | Should -Not -Throw
        #         { Get-GitHubOrganizationPendingInvitation -Organization $owner -InvitationSource 'member' } | Should -Not -Throw
        #     }
        #     It 'Remove-GitHubOrganizationInvitation - Removes a user invitation from an organization' {
        #         {
        #             $invitation = Get-GitHubOrganizationPendingInvitation -Organization $owner | Select-Object -First 1
        #             Remove-GitHubOrganizationInvitation -Organization $owner -ID $invitation.id
        #         } | Should -Not -Throw
        #     }
        # }
    }
}
