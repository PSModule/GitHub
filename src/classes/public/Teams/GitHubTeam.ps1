class GitHubTeam : GitHubNode {
    # The name of the team.
    [string] $Name

    # The slug of the team.
    [string] $Slug

    # The organization the team belongs to.
    [string] $Organization

    # The combined slug of the team.
    [string] $CombinedSlug

    # The description of the team.
    [string] $Description

    # The HTML URL of the team.
    # Example: https://github.com/orgs/github/teams/justice-league
    [string] $Url

    # The notification setting the team has chosen.
    # $true = notifications_enabled - team members receive notifications when the team is @mentioned.
    # $false = notifications_disabled - no one receives notifications.
    [bool] $Notifications = $true

    # The privacy setting of the team.
    # $true = closed - visible to all members of this organization.
    # $false = secret - only visible to organization owners and members of this team.
    [bool] $Visible = $true

    # The parent team of the team.
    [string] $ParentTeam

    # The child teams of the team.
    [string[]] $ChildTeams

    # The date and time the team was created.
    [datetime] $CreatedAt

    # The date and time the team was last updated.
    [datetime] $UpdatedAt

    # Simple parameterless constructor
    GitHubTeam() {}

    # Creates a object from a hashtable of key-vaule pairs.
    GitHubTeam([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a object from a PSCustomObject.
    GitHubTeam([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
