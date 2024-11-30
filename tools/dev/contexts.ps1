@{
    Common = @{
        ApiBaseUri = $ApiBaseUri
        ApiVersion = $ApiVersion
        HostName   = $HostName
        AuthType   = $authType # 'UAT', 'PAT', 'IAT', 'APP'
        Token      = $tokenResponse.access_token
        TokenType  = $AccessTokenType # 'UAT', 'PAT classic' 'PAT modern', 'PEM', 'IAT'
        id         = 'MariusStorhaug' # username/slug, clientid
    }
    UAT    = @{
        AuthAppClientID = $authClientID
        DeviceFlowType  = $Mode

        UATGHA          = @{
            TokenExpirationDate        = (Get-Date).AddSeconds($tokenResponse.expires_in)
            RefreshToken               = $tokenResponse.refresh_token
            RefreshTokenExpirationDate = (Get-Date).AddSeconds($tokenResponse.refresh_token_expires_in)
        }

        UATOAA          = @{
            Scope = $tokenResponse.scope
        }
    }
    PAT    = @{
        Token           = $accessTokenValue
        AccessTokenType = $accessTokenType
    }
    APP    = @{
        Token = $PEM
    } # => Generates JWT when used towards an org/user
    IAT    = @{
        Token           = $AccessToken
        AccessTokenType = $accessTokenType
    }
}
