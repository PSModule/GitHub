class GitHubRepositoryLanguage {
    # The name of the language.
    [string] $Name

    # The Node ID of the Language object.
    [string] $ID

    # The color defined for the current language.
    [string] $Color

    GitHubRepositoryLanguage() {}

    GitHubRepositoryLanguage([pscustomobject] $Object) {
        $this.Name = $Object.name
        $this.ID = $Object.id
        $this.Color = $Object.color
    }

    GitHubRepositoryLanguage([string] $Name) {
        $this.Name = $Name
    }

    [string] ToString() {
        return $this.Name
    }
}
