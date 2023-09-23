$script:ConfigTemplate = [pscustomobject]@{
    App  = [pscustomobject]@{
        API      = [pscustomobject]@{
            BaseURI = 'https://api.github.com' # $script:ConfigTemplate.App.API.BaseURI
            Version = '2022-11-28'             # $script:ConfigTemplate.App.API.Version
        }
        Defaults = [pscustomobject]@{}
    }
    User = [pscustomobject]@{
        Auth     = [pscustomobject]@{
            AccessToken  = [pscustomobject]@{
                Value          = ''  # $script:ConfigTemplate.User.Auth.AccessToken.Value
                ExpirationDate = [datetime]::MinValue  # $script:ConfigTemplate.User.Auth.AccessToken.ExpirationDate
            }
            ClientID     = ''        # $script:ConfigTemplate.User.Auth.ClientID
            Mode         = ''        # $script:ConfigTemplate.User.Auth.Mode
            RefreshToken = [pscustomobject]@{
                Value          = ''  # $script:ConfigTemplate.User.Auth.RefreshToken.Value
                ExpirationDate = [datetime]::MinValue  # $script:ConfigTemplate.User.Auth.RefreshToken.ExpirationDate
            }
            Scope        = ''               # $script:ConfigTemplate.User.Auth.Scope
        }
        Defaults = [pscustomobject]@{
            Owner = ''               # $script:ConfigTemplate.User.Defaults.Owner
            Repo  = ''               # $script:ConfigTemplate.User.Defaults.Repo
        }
    }
}
$script:Config = $script:ConfigTemplate
