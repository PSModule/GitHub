@{
    Common = @{
        ApiBaseUri = $ApiBaseUri
        ApiVersion = $ApiVersion
        HostName   = $HostName
        AuthType   = $authType # 'UAT', 'PAT', 'IAT', 'APP'
        Secret     = $tokenResponse.access_token
        SecretType = $AccessTokenType # 'UAT', 'PAT classic' 'PAT modern', 'PEM', 'IAT'
        id         = 'MariusStorhaug' # username/slug, clientid
    }
    UAT    = @{
        AuthAppClientID = $authClientID
        DeviceFlowType  = $Mode

        UATGHA          = @{
            SecretExpirationDate       = (Get-Date).AddSeconds($tokenResponse.expires_in)
            RefreshToken               = $tokenResponse.refresh_token
            RefreshTokenExpirationDate = (Get-Date).AddSeconds($tokenResponse.refresh_token_expires_in)
        }

        UATOAA          = @{
            Scope = $tokenResponse.scope
        }
    }
    PAT    = @{
        Secret          = $accessTokenValue
        AccessTokenType = $accessTokenType
    }
    APP    = @{
        Secret = $PEM
    } # => Generates JWT when used towards an org/user
    IAT    = @{
        Secret          = $AccessToken
        AccessTokenType = $accessTokenType
    }
}
