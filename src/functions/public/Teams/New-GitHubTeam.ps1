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
            Organization = 'github'
            Name         = 'team-name'
            Description  = 'A new team'
            Maintainers  = 'octocat'
            RepoNames    = 'github/octocat'
            Privacy      = 'closed'
            Permission   = 'pull'
        }
        New-GitHubTeam @params

        .NOTES
        [Create a team](https://docs.github.com/rest/teams/teams#create-a-team)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The name of the team.
        [Parameter(Mandatory)]
        [string] $Name,

        # The organization name. The name is not case sensitive.
        # If not provided, the organization from the context is used.
        [Parameter()]
        [Alias('Org')]
        [string] $Organization,

        # The description of the team.
        [Parameter()]
        [string] $Description,

        # List GitHub IDs for organization members who will become team maintainers.
        [Parameter()]
        [string[]] $Maintainers,

        # The full name (e.g., "organization-name/repository-name") of repositories to add the team to.
        [Parameter()]
        [string[]] $RepoNames,

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

        # Closing down notice. The permission that new repositories will be added to the team with when none is specified.
        [Parameter()]
        [ValidateSet('pull', 'push')]
        [string] $Permission = 'pull',

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

        if (-not $Visible -and $ParentTeamID -gt 0) {
            throw "A nested team cannot be secret (invisible)."
        }
    }

    process {
        try {
            $body = @{
                name                 = $Name
                description          = $Description
                maintainers          = $Maintainers
                repo_names           = $RepoNames
                privacy              = $Visible ? 'closed' : 'secret'
                notification_setting = $Notifications ? 'notifications_enabled' : 'notifications_disabled'
                permission           = $Permission
                parent_team_id       = $ParentTeamID -eq 0 ? $null : $ParentTeamID
            }
            $body | Remove-HashtableEntry -NullOrEmptyValues

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/orgs/$Organization/teams"
                Method      = 'POST'
                Body        = $body
            }

            if ($PSCmdlet.ShouldProcess("'$Name' in '$Organization'", 'Create team')) {
                Invoke-GitHubAPI @inputObject | ForEach-Object {
                    $team = $_.Response
                    [PSCustomObject]@{
                        Name          = $team.name
                        Slug          = $team.slug
                        NodeID        = $team.node_id
                        CombinedSlug  = $Organization + '/' + $team.slug
                        DatabaseId    = $team.id
                        Description   = $team.description
                        Notifications = $team.notification_setting -eq 'notifications_enabled' ? $true : $false
                        Visible       = $team.privacy -eq "closed" ? $true : $false
                        ParentTeam    = $team.parent.slug
                        Organization  = $team.organization.login
                        ChildTeams    = @()
                        CreatedAt     = $team.createdAt
                        UpdatedAt     = $team.updatedAt
                    }
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
