class GitHubRepositoryLanguage {
    # The name of the language.
    [string] $Name

    # The Node ID of the Language object.
    [int] $ID

    # The color defined for the current language.
    [string] $Color

    GitHubRepositoryLanguage([pscustomobject] $language) {
        $this.Name = $language.name
        $this.ID = $language.id
        $this.Color = $language.color
    }
}
