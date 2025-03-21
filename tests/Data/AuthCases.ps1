﻿@(
    @{
        AuthType      = 'PAT'
        Type          = 'a user'
        Case          = 'Fine-grained PAT token'
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
        Target        = 'this repository (GitHub)'
        Owner         = 'PSModule'
        Repo          = 'GitHub'
        OwnerType     = 'organization'
        ConnectParams = @{
            Token = $env:GITHUB_TOKEN
        }
    }
    @{
        AuthType         = 'App'
        Type             = 'a GitHub App from an Enterprise'
        Case             = 'PEM + IAT'
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
        Type             = 'a GitHub App from an Organization'
        Case             = 'PEM + IAT'
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
)
