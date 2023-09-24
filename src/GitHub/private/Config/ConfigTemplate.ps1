$script:ConfigTemplate = @{
    AccessTokenType            = '' 
    AccessToken                = ''
    AccessTokenExpirationDate  = [datetime]::MinValue.ToString()
    ApiBaseUri                 = 'https://api.github.com'
    ApiVersion                 = '2022-11-28'
    DefaultOwner               = '' #Default Owner for the current session
    DefaultRepo                = '' #Default Repo for the current session
    DeviceFlowType             = '' #OAuthApp,GitHubApp
    RefreshToken               = ''
    RefreshTokenExpirationDate = [datetime]::MinValue.ToString()
    Scope                      = '' #OAuth Scopes for the access token
    AuthType                   = '' #sPAT,PAT,DeviceFlow
    UserName                   = '' #GHUsername
}
