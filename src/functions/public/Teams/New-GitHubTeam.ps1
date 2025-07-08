function New-GitHubTeam {
    <#
        .SYNOPSIS
        Create a team

        .DESCRIPTION
        To create a team, the authenticated user must be a member or owner of `{org}`. By default, organization members can create teams.
        Organization owners can limit team creation to organization owners. For more information, see
        "[Setting team creation permissions](https://docs.github.com/articles/setting-team-creation-permissions-in-your-organization)."

        When you create a new team, you automatically become a team maintainer without explicitly adding yourself to the optional array of
        `maintainers`. For more information, see
        "[About teams](https://docs.github.com/github/setting-up-and-managing-organizations-and-teams/about-teams)".

        .EXAMPLE
        $params = @{
            Organization  = 'github'
            Name          = 'team-name'
            Description   = 'A new team'
            Visible       = $true
            Notifications = $true
        }
        New-GitHubTeam @params

        .LINK
        https://psmodule.io/GitHub/Functions/Teams/New-GitHubTeam

        .NOTES
        [Create a team](https://docs.github.com/rest/teams/teams#create-a-team)
    #>
    [OutputType([GitHubTeam])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The organization name. The name is not case sensitive.
        # If not provided, the organization from the context is used.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Organization,

        # The name of the team.
        [Parameter(Mandatory)]
        [string] $Name,

        # The description of the team.
        [Parameter()]
        [string] $Description,

        # List GitHub IDs for organization members who will become team maintainers.
        [Parameter()]
        [string[]] $Maintainers,

        # The level of privacy this team should have. The options are:
        # For a non-nested team:
        # - secret - only visible to organization owners and members of this team.
        # - closed - visible to all members of this organization.
        # Default: secret
        # For a parent or child team:
        # - closed - visible to all members of this organization.
        # Default for child team: closed
        [Parameter()]
        [bool] $Visible = $true,

        # The notification setting the team has chosen. The options are:
        # notifications_enabled - team members receive notifications when the team is @mentioned.
        # notifications_disabled - no one receives notifications.
        # Default: notifications_enabled
        [Parameter()]
        [bool] $Notifications = $true,

        # The ID of a team to set as the parent team.
        [Parameter()]
        [System.Nullable[int]] $ParentTeamID,

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

        if (-not $Visible -and $ParentTeamID -gt 0) {
            throw 'A nested team cannot be secret (invisible).'
        }
    }

    process {
        $body = @{
            name                 = $Name
            description          = $Description
            maintainers          = $Maintainers
            privacy              = $Visible ? 'closed' : 'secret'
            notification_setting = $Notifications ? 'notifications_enabled' : 'notifications_disabled'
            parent_team_id       = $ParentTeamID
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $apiParams = @{
            Method      = 'POST'
            APIEndpoint = "/orgs/$Organization/teams"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("team '$Name' in '$Organization'", 'Create')) {
            Invoke-GitHubAPI @apiParams | ForEach-Object {
                foreach ($team in $_.Response) {
                    [GitHubTeam]::new($team, $Organization)
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
