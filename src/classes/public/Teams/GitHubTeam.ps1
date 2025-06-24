class GitHubTeam : GitHubNode {
    # The name of the team.
    [string] $Name

    # The slug of the team.
    [string] $Slug

    # The organization the team belongs to.
    [string] $Organization

    # The description of the team.
    [string] $Description

    # The HTML URL of the team.
    # Example: https://github.com/orgs/github/teams/justice-league
    [string] $Url

    # The notification setting the team has chosen.
    # $true = notifications_enabled - team members receive notifications when the team is @mentioned.
    # $false = notifications_disabled - no one receives notifications.
    [System.Nullable[bool]] $Notifications

    # The privacy setting of the team.
    # $true = closed - visible to all members of this organization.
    # $false = secret - only visible to organization owners and members of this team.
    [System.Nullable[bool]] $Visible

    # The permission level of the team on a repository.
    # Example: @{ Admin = $true; Maintain = $true; Pull = $true; Triage = $true; Push = $true }
    [GitHubRepositoryPermission] $Permission

    GitHubTeam() {}

    GitHubTeam([PSCustomObject]$Object, [string]$Organization) {
        $this.ID = $Object.id
        $this.NodeID = $Object.node_id
        $this.Name = $Object.name
        $this.Slug = $Object.slug
        $this.Organization = $Organization
        $this.Description = $Object.description
        $this.Url = $Object.html_url
        $this.Notifications = $Object.notification_setting -eq 'notifications_enabled' ? $true : $false
        $this.Visible = $Object.privacy -eq 'closed' ? $true : $false
        $this.Permission = [GitHubRepositoryPermission]::new($Object.permissions)
    }
}
