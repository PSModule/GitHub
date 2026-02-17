class GitHubLabel : GitHubNode {
    # The name of the label
    # Example: "bug"
    [string] $Name

    # The repository where the label is
    [string] $Repository

    # The owner of the repository
    [string] $Owner

    # The description of the label
    # Example: "Something isn't working"
    [string] $Description

    # The color of the label (hex code without #)
    # Example: "d73a4a"
    [string] $Color

    # Whether this is a default label
    # Example: true
    [bool] $IsDefault

    # The API URL of the label
    # Example: "https://api.github.com/repos/octocat/Hello-World/labels/bug"
    [string] $Url

    # Constructor from API response
    GitHubLabel(
        [object] $data
    ) {
        $this.ID = $data.id
        $this.NodeID = $data.node_id
        $this.Name = $data.name
        $this.Description = $data.description
        $this.Color = $data.color
        $this.IsDefault = $data.default
        $this.Url = $data.url

        # Parse owner and repository from URL
        # URL format: https://api.github.com/repos/{owner}/{repo}/labels/{name}
        if ($data.url -match 'repos/([^/]+)/([^/]+)/labels') {
            $this.Owner = $matches[1]
            $this.Repository = $matches[2]
        }
    }
}
