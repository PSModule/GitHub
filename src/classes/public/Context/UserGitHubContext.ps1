class UserGitHubContext : GitHubContext {
    # The authentication client ID.
    # Client ID for UAT
    [string] $AuthClientID

    # The device flow type.
    # GitHubApp / OAuthApp
    [string] $DeviceFlowType

    # The scope when authenticating with OAuth.
    # 'gist read:org repo workflow'
    [string] $Scope

    # The token expiration date.
    # 2024-01-01-00:00:00
    [datetime] $TokenExpirationDate

    # The refresh token.
    [securestring] $RefreshToken

    # The refresh token expiration date.
    # 2024-01-01-00:00:00
    [datetime] $RefreshTokenExpirationDate
}
