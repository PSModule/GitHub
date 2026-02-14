class GitHubStamp {
    # The name of the stamp (region).
    # Example: 'Public'
    [string] $Name

    # The base URL of the status page for this stamp.
    # Example: 'https://www.githubstatus.com'
    [string] $BaseUrl

    GitHubStamp() {}

    GitHubStamp([string]$Name, [string]$BaseUrl) {
        $this.Name = $Name
        $this.BaseUrl = $BaseUrl
    }

    [string] ToString() {
        return $this.Name
    }
}
