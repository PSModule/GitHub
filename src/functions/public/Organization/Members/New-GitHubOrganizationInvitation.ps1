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

        .NOTES
        [Create an organization invitation](https://docs.github.com/rest/orgs/members#list-pending-organization-invitations)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Org')]
        [string] $Organization,

        # GitHub user ID for the person you are inviting.
        [Parameter(
            Mandatory,
            ParameterSetName = 'UserID'
        )]
        [Alias('invitee_id', 'user_id')]
        [int] $InviteeID,

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
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner: [$Owner]"
    }

    process {
        try {
            $body = @{
                invitee_id = $InviteeID
                email      = $Email
                role       = $Role
                team_ids   = $TeamIDs
            }
            $body | Remove-HashtableEntry -NullOrEmptyValues

            $inputObject = @{
                Context     = $Context
                Body        = $body
                Method      = 'post'
                APIEndpoint = "/orgs/$Organization/invitations"
            }

            if ($PSCmdlet.ShouldProcess("$InviteeID$Email to organization $Organization", 'Invite')) {
                Invoke-GitHubAPI @inputObject | ForEach-Object {
                    Write-Output $_.Response
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
