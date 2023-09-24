$script:ConfigTemplate = @{
    AccessTokenType            = '' #OAuth,App,Legacy,FineGrained
    AccessToken                = ''
    AccessTokenExpirationDate  = [datetime]::MinValue
    ApiBaseUri                 = 'https://api.github.com'
    ApiVersion                 = '2022-11-28'
    DefaultOwner               = '' #Default Owner for the current session
    DefaultRepo                = '' #Default Repo for the current session
    DeviceFlowType             = '' #OAuthApp,GitHubApp
    RefreshToken               = ''
    RefreshTokenExpirationDate = [datetime]::MinValue
    Scope                      = '' #OAuth Scopes for the access token
    AuthType                   = '' #sPAT,PAT,DeviceFlow
    UserName                   = '' #GHUsername
}
