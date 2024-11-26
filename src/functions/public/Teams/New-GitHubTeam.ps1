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
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Org')]
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
        [ValidateSet('secret', 'closed')]
        [string] $Privacy = 'closed',

        # The notification setting the team has chosen. The options are:
        # notifications_enabled - team members receive notifications when the team is @mentioned.
        # notifications_disabled - no one receives notifications.
        # Default: notifications_enabled
        [Parameter()]
        [ValidateSet('notifications_enabled', 'notifications_disabled')]
        [string] $NotificationSetting,

        # Closing down notice. The permission that new repositories will be added to the team with when none is specified.
        [Parameter()]
        [ValidateSet('pull', 'push')]
        [string] $Permission = 'pull',

        # The ID of a team to set as the parent team.
        [Parameter()]
        [int] $ParentTeamID,

        # The context to run the command in
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name DefaultContext)
    )

    $body = @{
        name                 = $Name
        description          = $Description
        maintainers          = $Maintainers
        repo_names           = $RepoNames
        privacy              = $Privacy
        notification_setting = $NotificationSetting
        permission           = $Permission
        parent_team_id       = $ParentTeamID
    }

    $body | Remove-HashtableEntry -NullOrEmptyValues

    $inputObject = @{
        Context     = $Context
        Method      = 'POST'
        Body        = $body
        APIEndpoint = "/orgs/$Organization/teams"
    }

    if ($PSCmdlet.ShouldProcess("'$Name' in '$Organization'", 'Create team')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
