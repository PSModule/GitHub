class GitHubReleaseNote {
    # Description: The file name of the asset
    # Example: "Team Environment"
    [string] $Name

    # Release notes or changelog, can be null
    # Example: "## What's Changed\n### Other Changes\n* Fix: Enhance repository deletion feedback and fix typo..."
    [string] $Notes

    GitHubReleaseNote() {}

    GitHubReleaseNote([PSCustomObject] $Object) {
        $this.Name = $Object.name
        $this.Notes = $Object.body
    }
}
