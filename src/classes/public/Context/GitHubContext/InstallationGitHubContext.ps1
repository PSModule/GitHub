class InstallationGitHubContext : GitHubContext {
    # Client ID for GitHub Apps
    [string] $ClientID

    # The token expiration date.
    # 2024-01-01-00:00:00
    [datetime] $TokenExpirationDate

    # The installation ID.
    [int] $InstallationID
}
