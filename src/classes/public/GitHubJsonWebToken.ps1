class GitHubJsonWebToken {
    # The secure JWT string used for GitHub API authentication
    [securestring] $Token

    # The timestamp when this token was issued (in UTC)
    [DateTime] $IssuedAt

    # The timestamp when this token will expire (in UTC)
    [DateTime] $ExpiresAt

    # The ClientID for the GitHub App
    [string] $Issuer

    GitHubJsonWebToken() {}
}
