@(
    @{
        AuthType      = 'PAT'
        Type          = 'a user'
        Case          = 'Fine-grained PAT token'
        TokenType     = 'USER_FG_PAT'
        Target        = 'it self (user account)'
        Owner         = 'psmodule-user'
        OwnerType     = 'user'
        ConnectParams = @{
            Token = $env:TEST_USER_USER_FG_PAT
        }
    }
    @{
        AuthType      = 'PAT'
        Type          = 'a user'
        Case          = 'Fine-grained PAT token'
        TokenType     = 'ORG_FG_PAT'
        Target        = 'organization account'
        Owner         = 'psmodule-test-org2'
        OwnerType     = 'organization'
        ConnectParams = @{
            Token = $env:TEST_USER_ORG_FG_PAT
        }
    }
    @{
        AuthType      = 'PAT'
        Type          = 'a user'
        Case          = 'Classic PAT token'
        TokenType     = 'PAT'
        Target        = 'user account'
        Owner         = 'psmodule-user'
        OwnerType     = 'user'
        ConnectParams = @{
            Token = $env:TEST_USER_PAT
        }
    }
    @{
        AuthType      = 'IAT'
        Type          = 'GitHub Actions'
        Case          = 'GITHUB_TOKEN'
        TokenType     = 'GITHUB_TOKEN'
        Target        = 'this repository (GitHub)'
        Owner         = 'PSModule'
        Repo          = 'GitHub'
        OwnerType     = 'repository'
        ConnectParams = @{
            Token = $env:GITHUB_TOKEN
        }
    }
    @{
        AuthType         = 'App'
        Type             = 'a GitHub App from an Organization'
        Case             = 'JWT + IAT'
        TokenType        = 'APP_ORG'
        Target           = 'organization account'
        Owner            = 'psmodule-test-org'
        OwnerType        = 'organization'
        ConnectParams    = @{
            ClientID   = $env:TEST_APP_ORG_CLIENT_ID
            PrivateKey = $env:TEST_APP_ORG_PRIVATE_KEY
        }
        ConnectAppParams = @{
            Organization = 'psmodule-test-org'
        }
    }
    @{
        AuthType         = 'App'
        Type             = 'a GitHub App from an Enterprise'
        Case             = 'JWT + IAT'
        TokenType        = 'APP_ENT'
        Target           = 'organization account'
        Owner            = 'psmodule-test-org3'
        OwnerType        = 'organization'
        ConnectParams    = @{
            ClientID   = $env:TEST_APP_ENT_CLIENT_ID
            PrivateKey = $env:TEST_APP_ENT_PRIVATE_KEY
        }
        ConnectAppParams = @{
            Organization = 'psmodule-test-org3'
        }
    }
    @{
        AuthType         = 'App'
        Type             = 'a GitHub App from an Enterprise'
        Case             = 'JWT + IAT'
        TokenType        = 'APP_ENT'
        Target           = 'enterprise account'
        Owner            = 'msx'
        OwnerType        = 'enterprise'
        ConnectParams    = @{
            ClientID   = $env:TEST_APP_ENT_CLIENT_ID
            PrivateKey = $env:TEST_APP_ENT_PRIVATE_KEY
        }
        ConnectAppParams = @{
            Enterprise = 'msx'
        }
    }
)
