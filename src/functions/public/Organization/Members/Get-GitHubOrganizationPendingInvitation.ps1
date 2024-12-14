﻿function Get-GitHubOrganizationPendingInvitation {
    <#
        .SYNOPSIS
        List pending organization invitations

        .DESCRIPTION
        The return hash contains a `role` field which refers to the Organization
        Invitation role and will be one of the following values: `direct_member`, `admin`,
        `billing_manager`, or `hiring_manager`. If the invitee is not a GitHub
        member, the `login` field in the return hash will be `null`.

        .NOTES
        [List pending organization invitations](https://docs.github.com/rest/orgs/members#list-pending-organization-invitations)
    #>
    [CmdletBinding()]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Org')]
        [string] $Organization,

        # Filter invitations by their member role.
        [Parameter()]
        [ValidateSet('all', 'admin', 'direct_member', 'billing_manager', 'hiring_manager')]
        [string] $Role = 'all',

        # Filter invitations by their invitation source.
        [Parameter()]
        [ValidateSet('all', 'member', 'scim')]
        [string] $InvitationSource = 'all',

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    if ([string]::IsNullOrEmpty($Owner)) {
        $Organization = $Context.Owner
    }
    Write-Debug "Organization : [$($Context.Owner)]"

    $body = @{
        role              = $Role
        invitation_source = $InvitationSource
        per_page          = $PerPage
    }

    $inputObject = @{
        Context     = $Context
        Body        = $body
        Method      = 'Get'
        APIEndpoint = "/orgs/$Organization/invitations"
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
