$script:ConfigTemplate = [pscustomobject]@{             # $script:ConfigTemplate
    App  = [pscustomobject]@{                           # $script:ConfigTemplate.App
        API      = [pscustomobject]@{                   # $script:ConfigTemplate.App.API
            BaseURI = 'https://api.github.com'          # $script:ConfigTemplate.App.API.BaseURI
            Version = '2022-11-28'                      # $script:ConfigTemplate.App.API.Version
        }
        Defaults = [pscustomobject]@{}                  # $script:ConfigTemplate.App.Defaults
    }
    User = [pscustomobject]@{                           # $script:ConfigTemplate.User
        Auth     = [pscustomobject]@{                   # $script:ConfigTemplate.User.Auth
            AccessToken  = [pscustomobject]@{           # $script:ConfigTemplate.User.Auth.AccessToken
                Value          = ''                     # $script:ConfigTemplate.User.Auth.AccessToken.Value
                ExpirationDate = [datetime]::MinValue   # $script:ConfigTemplate.User.Auth.AccessToken.ExpirationDate
            }
            ClientID     = ''                           # $script:ConfigTemplate.User.Auth.ClientID
            Mode         = ''                           # $script:ConfigTemplate.User.Auth.Mode
            RefreshToken = [pscustomobject]@{
                Value          = ''                     # $script:ConfigTemplate.User.Auth.RefreshToken.Value
                ExpirationDate = [datetime]::MinValue   # $script:ConfigTemplate.User.Auth.RefreshToken.ExpirationDate
            }
            Scope        = ''                           # $script:ConfigTemplate.User.Auth.Scope
        }
        Defaults = [pscustomobject]@{                   # $script:ConfigTemplate.User.Defaults
            Owner = ''                                  # $script:ConfigTemplate.User.Defaults.Owner
            Repo  = ''                                  # $script:ConfigTemplate.User.Defaults.Repo
        }
    }
}
