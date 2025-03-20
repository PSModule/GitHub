@(
    @{
        Type           = 'a user'
        Case           = 'Fine-grained PAT token'
        Target         = 'it self (user account)'
        Owner          = 'psmodule-user'
        $connectParams = @{
            Token = $env:TEST_USER_USER_FG_PAT
        }
    }
    @{
        Type           = 'a user'
        Case           = 'Fine-grained PAT token'
        Target         = 'organization account'
        Owner          = 'psmodule-test-org2'
        $connectParams = @{
            Token = $env:TEST_USER_ORG_FG_PAT
        }
    }
    @{
        Type           = 'a user'
        Case           = 'Classic PAT token'
        Target         = 'user account'
        Owner          = 'psmodule-user'
        $connectParams = @{
            Token = $env:TEST_USER_PAT
        }
    }
    @{
        Type           = 'GitHub Actions'
        Case           = 'GITHUB_TOKEN'
        Target         = 'this repository (GitHub)'
        Owner          = 'PSModule'
        $connectParams = @{
            Token = $env:GITHUB_TOKEN
        }
    }
    @{
        Type              = 'a GitHub App from an Enterprise'
        Case              = 'PEM + IAT'
        Target            = 'organization account'
        Owner             = 'psmodule-test-org3'
        $connectParams    = @{
            ClientID    = $env:TEST_APP_ENT_CLIENT_ID
            $PrivateKey = $env:TEST_APP_ENT_PRIVATE_KEY
        }
        $connectAppParams = @{
            Organization = 'psmodule-test-org3'
        }
    }
    @{
        Type              = 'a GitHub App from an Organization'
        Case              = 'PEM + IAT'
        Target            = 'organization account'
        Owner             = 'psmodule-test-org'
        $connectParams    = @{
            ClientID    = $env:TEST_APP_ORG_CLIENT_ID
            $PrivateKey = $env:TEST_APP_ORG_PRIVATE_KEY
        }
        $connectAppParams = @{
            Organization = 'psmodule-test-org'
        }
    }
)
