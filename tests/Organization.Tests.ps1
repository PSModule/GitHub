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

Describe 'As a user - Fine-grained PAT token - user account access (USER_FG_PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_USER_FG_PAT
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
}

Describe 'As a user - Fine-grained PAT token - organization account access (ORG_FG_PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_ORG_FG_PAT
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Organization' {
        It 'Get-GitHubOrganization - Gets the organizations for the authenticated user (ORG_FG_PAT)' {
            { Get-GitHubOrganization } | Should -Not -Throw
        }
        It 'Get-GitHubOrganization - Gets a specific organization (ORG_FG_PAT)' {
            { Get-GitHubOrganization -Organization 'psmodule-test-org2' } | Should -Not -Throw
        }
        It "Get-GitHubOrganization - List public organizations for the user 'psmodule-user'. (ORG_FG_PAT)" {
            { Get-GitHubOrganization -Username 'psmodule-user' } | Should -Not -Throw
        }
        It 'Get-GitHubOrganizationMember - Gets the members of a specific organization (ORG_FG_PAT)' {
            $members = Get-GitHubOrganizationMember -Organization 'psmodule-test-org2'
            $members.login | Should -Contain 'psmodule-user'
        }
        It 'Update-GitHubOrganization - Sets the organization configuration (ORG_FG_PAT)' {
            { Update-GitHubOrganization -Organization 'psmodule-test-org2' -Company 'ABC' } | Should -Not -Throw
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                Update-GitHubOrganization -Organization 'psmodule-test-org2' -BillingEmail $email
            } | Should -Not -Throw
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                Update-GitHubOrganization -Organization 'psmodule-test-org2' -Email $email
            } | Should -Not -Throw
            {
                Update-GitHubOrganization -Organization 'psmodule-test-org2' -TwitterUsername 'PSModule'
            } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org2' -Location 'USA' } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org2' -Description 'Test Organization' } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org2' -DefaultRepositoryPermission read } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org2' -MembersCanCreateRepositories $true } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org2' -Blog 'https://psmodule.io' } | Should -Not -Throw
        }
        It 'New-GitHubOrganizationInvitation - Invites a user to an organization (ORG_FG_PAT)' {
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                New-GitHubOrganizationInvitation -Organization 'psmodule-test-org2' -Email $email -Role 'admin'
            } | Should -Not -Throw
        }
        It 'Get-GitHubOrganizationPendingInvitation - Gets the pending invitations for a specific organization (ORG_FG_PAT)' {
            { Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org2' } | Should -Not -Throw
            { Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org2' -Role 'admin' } | Should -Not -Throw
            { Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org2' -InvitationSource 'member' } | Should -Not -Throw
        }
        It 'Remove-GitHubOrganizationInvitation - Removes a user invitation from an organization (ORG_FG_PAT)' {
            {
                $invitation = Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org2' | Select-Object -First 1
                Remove-GitHubOrganizationInvitation -Organization 'psmodule-test-org2' -ID $invitation.id
            } | Should -Not -Throw
        }
    }
}

Describe 'As a user - Classic PAT token (PAT)' {
    BeforeAll {
        Connect-GitHubAccount -Token $env:TEST_USER_PAT
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Organization' {
        It 'Get-GitHubOrganization - Gets the organizations for the authenticated user (PAT)' {
            { Get-GitHubOrganization } | Should -Not -Throw
        }
        It 'Get-GitHubOrganization - Gets a specific organization (PAT)' {
            { Get-GitHubOrganization -Organization 'psmodule-test-org2' } | Should -Not -Throw
        }
        It "Get-GitHubOrganization - List public organizations for the user 'psmodule-user'. (PAT)" {
            { Get-GitHubOrganization -Username 'psmodule-user' } | Should -Not -Throw
        }
        It 'Get-GitHubOrganizationMember - Gets the members of a specific organization (PAT)' {
            $members = Get-GitHubOrganizationMember -Organization 'psmodule-test-org2'
            $members.login | Should -Contain 'psmodule-user'
        }
    }
}

Describe 'As GitHub Actions (GHA)' {
    BeforeAll {
        Connect-GitHubAccount
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
}

Describe 'As a GitHub App - Enterprise (APP_ENT)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ENT_CLIENT_ID -PrivateKey $env:TEST_APP_ENT_PRIVATE_KEY
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Organization' {
        BeforeAll {
            Connect-GitHubApp -Organization 'psmodule-test-org3' -Default
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
        It 'Get-GitHubOrganization - Gets a specific organization (APP_ENT)' {
            { Get-GitHubOrganization -Organization 'psmodule-test-org3' } | Should -Not -Throw
        }
        It 'Get-GitHubAppInstallation - Gets the GitHub App installations on the organization (APP_ENT)' {
            $installations = Get-GitHubAppInstallation -Organization 'psmodule-test-org3'
            Write-Verbose ($installations | Format-Table | Out-String) -Verbose
            $installations | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubOrganizationMember - Gets the members of a specific organization (APP_ENT)' {
            $members = Get-GitHubOrganizationMember -Organization 'psmodule-test-org3'
            $members.login | Should -Contain 'MariusStorhaug'
        }
        It 'Update-GitHubOrganization - Sets the organization configuration (APP_ENT)' {
            { Update-GitHubOrganization -Organization 'psmodule-test-org3' -Company 'ABC' } | Should -Not -Throw
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                Update-GitHubOrganization -Organization 'psmodule-test-org3' -BillingEmail $email
            } | Should -Not -Throw
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                Update-GitHubOrganization -Organization 'psmodule-test-org3' -Email $email
            } | Should -Not -Throw
            {
                Update-GitHubOrganization -Organization 'psmodule-test-org3' -TwitterUsername 'PSModule'
            } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org3' -Location 'USA' } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org3' -Description 'Test Organization' } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org3' -DefaultRepositoryPermission read } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org3' -MembersCanCreateRepositories $true } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org3' -Blog 'https://psmodule.io' } | Should -Not -Throw
        }
    }
}

Describe 'As a GitHub App - Organization (APP_ORG)' {
    BeforeAll {
        Connect-GitHubAccount -ClientID $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
    }
    AfterAll {
        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
    }
    Context 'Organization' {
        BeforeAll {
            Connect-GitHubApp -Organization 'psmodule-test-org' -Default
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
        It 'Get-GitHubOrganization - Gets a specific organization (APP_ORG)' {
            { Get-GitHubOrganization -Organization 'psmodule-test-org' } | Should -Not -Throw
        }
        It 'Get-GitHubAppInstallation - Gets the GitHub App installations on the organization (APP_ORG)' {
            $installations = Get-GitHubAppInstallation -Organization 'psmodule-test-org'
            Write-Verbose ($installations | Format-Table | Out-String) -Verbose
            $installations | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubOrganizationMember - Gets the members of a specific organization (APP_ORG)' {
            $members = Get-GitHubOrganizationMember -Organization 'psmodule-test-org'
            $members.login | Should -Contain 'MariusStorhaug'
        }
        It 'Update-GitHubOrganization - Sets the organization configuration (APP_ORG)' {
            { Update-GitHubOrganization -Organization 'psmodule-test-org' -Company 'ABC' } | Should -Not -Throw
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                Update-GitHubOrganization -Organization 'psmodule-test-org' -BillingEmail $email
            } | Should -Not -Throw
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                Update-GitHubOrganization -Organization 'psmodule-test-org' -Email $email
            } | Should -Not -Throw
            {
                Update-GitHubOrganization -Organization 'psmodule-test-org' -TwitterUsername 'PSModule'
            } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org' -Location 'USA' } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org' -Description 'Test Organization' } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org' -DefaultRepositoryPermission read } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org' -MembersCanCreateRepositories $true } | Should -Not -Throw
            { Update-GitHubOrganization -Organization 'psmodule-test-org' -Blog 'https://psmodule.io' } | Should -Not -Throw
        }
        It 'New-GitHubOrganizationInvitation - Invites a user to an organization (APP_ORG)' {
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                New-GitHubOrganizationInvitation -Organization 'psmodule-test-org' -Email $email -Role 'admin'
            } | Should -Not -Throw
        }
        It 'Get-GitHubOrganizationPendingInvitation - Gets the pending invitations for a specific organization (APP_ORG)' {
            { Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org' } | Should -Not -Throw
            { Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org' -Role 'admin' } | Should -Not -Throw
            { Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org' -InvitationSource 'member' } | Should -Not -Throw
        }
        It 'Remove-GitHubOrganizationInvitation - Removes a user invitation from an organization (APP_ORG)' {
            {
                $invitation = Get-GitHubOrganizationPendingInvitation -Organization 'psmodule-test-org' | Select-Object -First 1
                Remove-GitHubOrganizationInvitation -Organization 'psmodule-test-org' -ID $invitation.id
            } | Should -Not -Throw
        }
    }
}
