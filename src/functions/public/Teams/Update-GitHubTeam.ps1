function Update-GitHubTeam {
    <#
        .SYNOPSIS
        Update a team

        .DESCRIPTION
        To edit a team, the authenticated user must either be an organization owner or a team maintainer.

        .EXAMPLE
        $params = @{
            Organization  = 'github'
            Slug          = 'team-name'
            NewName       = 'new team name'
            Description   = 'A new team'
            Visible       = $true
            Notifications = $true
            Permission    = 'pull'
            ParentTeamID  = 123456
        }
        Update-GitHubTeam @params

        Updates the team with the slug 'team-name' in the `github` organization with the new name 'new team name', description 'A new team',
        visibility set to 'closed', notifications enabled, permission set to 'pull', and the parent team ID set to 123456.

        .NOTES
        [Update a team](https://docs.github.com/en/rest/teams/teams?apiVersion=2022-11-28#update-a-team)
    #>
    [OutputType([GitHubTeam])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The slug of the team name.
        [Parameter(Mandatory)]
        [Alias('team_slug')]
        [string] $Slug,

        # The organization name. The name is not case sensitive.
        # If you do not provide this parameter, the command will use the organization from the context.
        [Parameter()]
        [Alias('Org')]
        [string] $Organization,

        # The new team name.
        [Parameter()]
        [Alias()]
        [string] $Name,

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

        # Closing down notice. The permission that new repositories will be added to the team with when none is specified.
        [Parameter()]
        [ValidateSet('pull', 'push')]
        [string] $Permission,

        # The ID of a team to set as the parent team.
        [Parameter()]
        [int] $ParentTeamID,

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

        if ([string]::IsNullOrEmpty($Organization)) {
            $Organization = $Context.Owner
        }
        Write-Debug "Organization: [$Organization]"
    }

    process {
        try {
            $body = @{
                name                 = $Name
                description          = $Description
                privacy              = $PSBoundParameters.ContainsKey('Visible') ? ($Visible ? 'closed' : 'secret') : $null
                notification_setting = $PSBoundParameters.ContainsKey('Notifications') ?
                    ($Notifications ? 'notifications_enabled' : 'notifications_disabled') : $null
                permission           = $Permission
                parent_team_id       = $ParentTeamID -eq 0 ? $null : $ParentTeamID
            }
            $body | Remove-HashtableEntry -NullOrEmptyValues

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/orgs/$Organization/teams/$Slug"
                Method      = 'Patch'
                Body        = $body
            }

            if ($PSCmdlet.ShouldProcess("$Organization/$Slug", 'Update')) {
                Invoke-GitHubAPI @inputObject | ForEach-Object {
                    $team = $_.Response
                    [GitHubTeam](
                        @{
                            Name          = $team.name
                            Slug          = $team.slug
                            NodeID        = $team.node_id
                            CombinedSlug  = $Organization + '/' + $team.slug
                            DatabaseId    = $team.id
                            Description   = $team.description
                            Notifications = $team.notification_setting -eq 'notifications_enabled' ? $true : $false
                            Visible       = $team.privacy -eq 'closed' ? $true : $false
                            ParentTeam    = $team.parent.slug
                            Organization  = $team.organization.login
                            ChildTeams    = @()
                            CreatedAt     = $team.created_at
                            UpdatedAt     = $team.updated_at
                        }
                    )
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
