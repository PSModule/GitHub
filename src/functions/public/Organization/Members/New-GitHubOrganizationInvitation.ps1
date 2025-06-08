function New-GitHubOrganizationInvitation {
    <#
        .SYNOPSIS
        Create an organization invitation

        .DESCRIPTION
        Invite people to an organization by using their GitHub user ID or their email address. In order to create invitations in an organization,
        the authenticated user must be an organization owner.

        This endpoint triggers [notifications](https://docs.github.com/github/managing-subscriptions-and-notifications-on-github/about-notifications).
        Creating content too quickly using this endpoint may result in secondary rate limiting. For more information, see
        "[Rate limits for the API](https://docs.github.com/rest/using-the-rest-api/rate-limits-for-the-rest-api#about-secondary-rate-limits)"
        and "[Best practices for using the REST API](https://docs.github.com/rest/guides/best-practices-for-using-the-rest-api)."

        .EXAMPLE
        New-GitHubOrganizationInvitation -Organization 'PSModule' -InviteeID 123456789 -Role 'admin'

        Invites the user with the ID `12345679` to the organization `PSModule` with the role `admin`.

        .EXAMPLE
        New-GitHubOrganizationInvitation -Organization 'PSModule' -Email 'user@psmodule.io'

        Invites the user with the email `user@psmodule.io` to the organization `PSModule`.

        .NOTES
        [Create an organization invitation](https://docs.github.com/rest/orgs/members#list-pending-organization-invitations)

        .LINK
        https://psmodule.io/GitHub/Functions/Organization/Members/New-GitHubOrganizationInvitation
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Organization,

        # GitHub user ID for the person you are inviting.
        [Parameter(
            Mandatory,
            ParameterSetName = 'UserID'
        )]
        [System.Nullable[int]] $ID,

        # Email address of the person you are inviting, which can be an existing GitHub user.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Email'
        )]
        [string] $Email,

        # The role for the new member.
        #
        # - `admin` - Organization owners with full administrative rights to the organization and complete access to all repositories and teams.
        # - `direct_member` - Non-owner organization members with ability to see other members and join teams by invitation.
        # - `billing_manager` - Non-owner organization members with ability to manage the billing settings of your organization.
        # - `reinstate` - The previous role assigned to the invitee before they were removed from your organization.
        #   Can be one of the roles listed above.
        # Only works if the invitee was previously part of your organization.
        [Parameter()]
        [ValidateSet('admin', 'direct_member', 'billing_manager', 'reinstate')]
        [string] $Role = 'direct_member',

        # Specify IDs for the teams you want to invite new members to.
        [Parameter()]
        [int[]] $TeamIDs,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            invitee_id = $ID
            email      = $Email
            role       = $Role
            team_ids   = $TeamIDs
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = "/orgs/$Organization/invitations"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("$InviteeID$Email to organization $Organization", 'Invite')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
