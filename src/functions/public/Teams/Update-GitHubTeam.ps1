function Update-GitHubTeam {
    <#
        .SYNOPSIS
        Update a team

        .DESCRIPTION
        To edit a team, the authenticated user must either be an organization owner or a team maintainer.

        .EXAMPLE
        $params = @{
            Organization        = 'github'
            Name                = 'team-name'
            NewName             = 'new-team-name'
            Description         = 'A new team'
            Privacy             = 'closed'
            NotificationSetting = 'notifications_enabled'
            Permission          = 'pull'
            ParentTeamID        = 123456
        }
        Update-GitHubTeam @params

        .NOTES
        [Update a team](https://docs.github.com/en/rest/teams/teams?apiVersion=2022-11-28#update-a-team)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Org')]
        [string] $Organization,

        # The slug of the team name.
        [Parameter(Mandatory)]
        [Alias('Team', 'TeamName', 'slug', 'team_slug')]
        [string] $Name,

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
        name                 = $NewName
        description          = $Description
        privacy              = $Privacy
        notification_setting = $NotificationSetting
        permission           = $Permission
        parent_team_id       = $ParentTeamID
    }

    $body | Remove-HashtableEntry -NullOrEmptyValues

    $inputObject = @{
        Context     = $Context
        Method      = 'Patch'
        APIEndpoint = "/orgs/$Organization/teams/$Name"
        Body        = $body
    }

    if ($PSCmdlet.ShouldProcess("$Organization/$Name", 'Update')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
