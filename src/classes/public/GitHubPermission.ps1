class GitHubPermission {
    # The programmatic name of the permission as returned by the GitHub API
    [string] $Name

    # The human-friendly name of the permission as shown in the GitHub UI
    [string] $DisplayName

    # A brief description of what access the permission grants
    [string] $Description

    # A link to the relevant documentation or GitHub UI page
    [uri] $URL

    # The levels of access that can be granted for this permission
    [string[]] $Options

    # The type of permission (Fine-grained, Classic)
    [string] $Type

    # The scope at which this permission applies (Repository, Organization, User, Enterprise)
    [string] $Scope

    GitHubPermission() {}

    GitHubPermission([string]$Name, [string]$DisplayName, [string]$Description, [string]$URL, [string[]]$Options, [string]$Type, [string]$Scope) {
        $this.Name = $Name
        $this.DisplayName = $DisplayName
        $this.Description = $Description
        $this.URL = [uri]$URL
        $this.Options = $Options
        $this.Type = $Type
        $this.Scope = $Scope
    }

    [string] ToString() {
        return $this.Name
    }
}
