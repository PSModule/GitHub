function Update-GitHubTeam {
    <#
        .SYNOPSIS
        Update a team

        .DESCRIPTION
        To edit a team, the authenticated user must either be an organization owner or a team maintainer.

        .EXAMPLE
        ```pwsh
        $params = @{
            Organization  = 'github'
            Slug          = 'team-name'
            NewName       = 'new team name'
            Description   = 'A new team'
            Visible       = $true
            Notifications = $true
            ParentTeamID  = 123456
        }
        Update-GitHubTeam @params
        ```

        Updates the team with the slug 'team-name' in the `github` organization with the new name 'new team name', description 'A new team',
        visibility set to 'closed', notifications enabled, and the parent team ID set to 123456.

        .NOTES
        [Update a team](https://docs.github.com/rest/teams/teams#update-a-team)

        .LINK
        https://psmodule.io/GitHub/Functions/Teams/Update-GitHubTeam
    #>
    [OutputType([GitHubTeam])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The organization name. The name is not case sensitive.
        # If you do not provide this parameter, the command will use the organization from the context.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Organization,

        # The slug of the team name.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Slug,

        # The new team name.
        [Parameter()]
        [Alias()]
        [string] $NewName,

        # The description of the team.
        [Parameter()]
        [string] $Description,

        # The level of privacy this team should have. The options are:
        # For a non-nested team:
        # - secret - only visible to organization owners and members of this team.
        # - closed - visible to all members of this organization.
        # Default: secret
        # For a parent or child team:
        # - closed - visible to all members of this organization.
        # Default for child team: closed
        [Parameter()]
        [bool] $Visible,

        # The notification setting the team has chosen. The options are:
        # notifications_enabled - team members receive notifications when the team is @mentioned.
        # notifications_disabled - no one receives notifications.
        # Default: notifications_enabled
        [Parameter()]
        [bool] $Notifications,

        # The ID of a team to set as the parent team.
        [Parameter()]
        [int] $ParentTeamID,

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
            name                 = $NewName
            description          = $Description
            privacy              = $PSBoundParameters.ContainsKey('Visible') ? ($Visible ? 'closed' : 'secret') : $null
            notification_setting = $PSBoundParameters.ContainsKey('Notifications') ? (
                $Notifications ? 'notifications_enabled' : 'notifications_disabled'
            ) : $null
            parent_team_id       = $ParentTeamID -eq 0 ? $null : $ParentTeamID
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $apiParams = @{
            Method      = 'PATCH'
            APIEndpoint = "/orgs/$Organization/teams/$Slug"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("$Organization/$Slug", 'Update')) {
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
