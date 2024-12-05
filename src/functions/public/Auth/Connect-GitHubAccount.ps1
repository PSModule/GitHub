function Connect-GitHubAccount {
    <#
        .SYNOPSIS
        Connects to GitHub.

        .DESCRIPTION
        Connects to GitHub using one of the following logon methods:
        - a personal access token
        - device code login (interactive user login)
        - a system access token (for GitHub Actions)
        - a GitHub App using JWT or installation access token

        For device flow / device code login:
        PowerShell requests device and user verification codes and gets the authorization URL where you will enter the user verification code.
        In GitHub you will be asked to enter a user verification code at <https://github.com/login/device>.
        PowerShell will keep polling GitHub for the user authentication status. Once you have authorized the device,
        the app will be able to make API calls with a new access token.

        .EXAMPLE
        Connect-GitHubAccount

        Connects to GitHub using a device flow login.
        If the user has already logged in, the access token will be refreshed.

        .EXAMPLE
        $env:GH_TOKEN = '***'
        Connect-GitHubAccount

        Connects to GitHub using the access token from environment variable, assuming unattended mode.

        .EXAMPLE
        Connect-GitHubAccount -UseAccessToken
        ! Enter your personal access token: *************

        User gets prompted for the access token and stores it in the context.
        The token is used when connecting to GitHub.

        .EXAMPLE
        Connect-GitHubAccount -Mode 'OAuthApp' -Scope 'gist read:org repo workflow'

        Connects to GitHub using a device flow login and sets the scope of the access token.

        .NOTES
        [Authenticating to the REST API](https://docs.github.com/rest/overview/other-authentication-methods#authenticating-for-saml-sso)
    #>
    [Alias('Connect-GHAccount')]
    [Alias('Connect-GitHub')]
    [Alias('Connect-GH')]
    [Alias('Login-GitHubAccount')]
    [Alias('Login-GHAccount')]
    [Alias('Login-GitHub')]
    [Alias('Login-GH')]
    [OutputType([void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Long links for documentation.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Is the CLI part of the module.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'The tokens are recieved as clear text. Mitigating exposure by removing variables and performing garbage collection.')]
    [CmdletBinding(DefaultParameterSetName = 'UAT')]
    param(
        # Choose between authentication methods, either OAuthApp or GitHubApp.
        # For more info about the types of authentication visit:
        # [Differences between GitHub Apps and OAuth apps](https://docs.github.com/apps/oauth-apps/building-oauth-apps/differences-between-github-apps-and-oauth-apps)
        [Parameter(ParameterSetName = 'UAT')]
        [ValidateSet('OAuthApp', 'GitHubApp')]
        [string] $Mode = 'GitHubApp',

        # The scope of the access token, when using OAuth authentication.
        # Provide the list of scopes as space-separated values.
        # For more information on scopes visit:
        # [Scopes for OAuth apps](https://docs.github.com/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps)
        [Parameter(ParameterSetName = 'UAT')]
        [string] $Scope = 'gist read:org repo workflow',


        # The user will be prompted to enter the token.
        [Parameter(
            Mandatory,
            ParameterSetName = 'PAT'
        )]
        [switch] $UseAccessToken,

        # An access token to use for authentication. Can be both a string or a SecureString.
        # Supports both personal access tokens (PAT) and GitHub App installation access tokens (IAT).
        # Example: 'ghp_1234567890abcdef'
        # Example: 'ghs_1234567890abcdef'
        [Parameter(
            Mandatory,
            ParameterSetName = 'Token'
        )]
        [object] $Token,

        # The client ID for the GitHub App to use for authentication.
        [Parameter(ParameterSetName = 'UAT')]
        [Parameter(
            Mandatory,
            ParameterSetName = 'App'
        )]
        [string] $ClientID,

        # The private key for the GitHub App when authenticating as a GitHub App.
        [Parameter(
            Mandatory,
            ParameterSetName = 'App'
        )]
        [string] $PrivateKey,

        # The default enterprise to use in commands.
        [Parameter()]
        [string] $Enterprise,

        # Set the default owner to use in commands.
        [Parameter()]
        [Alias('Organization')]
        [Alias('Org')]
        [string] $Owner = $env:GITHUB_REPOSITORY_OWNER,

        # Set the default repository to use in commands.
        [Parameter()]
        [Alias('Repository')]
        [string] $Repo = $env:GITHUB_REPOSITORY_NAME,

        # API version used for API requests.
        [Parameter()]
        [string] $ApiVersion = '2022-11-28',

        # The host to connect to. Can use $env:GITHUB_SERVER_URL to set the host, as the protocol is removed automatically.
        # Example: github.com, github.enterprise.com, msx.ghe.com
        [Parameter()]
        [Alias('Host')]
        [Alias('Server')]
        [string] $HostName,

        # Suppresses the output of the function.
        [Parameter()]
        [Alias('Quiet')]
        [Alias('q')]
        [Alias('s')]
        [switch] $Silent,

        # Make the connected context NOT the default context.
        [Parameter()]
        [switch] $NotDefault
    )

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    try {
        if ($Token -is [System.Security.SecureString]) {
            $Token = ConvertFrom-SecureString $Token -AsPlainText
        }

        $gitHubConfig = Get-GitHubConfig
        if (-not $HostName) {
            $HostName = $gitHubConfig.DefaultHostName
        }
        $HostName = $HostName -replace '^https?://'
        $ApiBaseUri = "https://api.$HostName"
        $authType = $PSCmdlet.ParameterSetName

        # If running on GitHub Actions and no access token is provided, use the GitHub token.
        if (($env:GITHUB_ACTIONS -eq 'true') -and $PSCmdlet.ParameterSetName -ne 'App') {
            $tokenNotProvided = [string]::IsNullOrEmpty($Token)
            $gitHubToken = $env:GH_TOKEN ?? $env:GITHUB_TOKEN
            $gitHubTokenPresent = -not [string]::IsNullOrEmpty($gitHubToken)
            Write-Verbose "Token not provided:    [$tokenNotProvided]"
            Write-Verbose "GitHub token present:  [$gitHubTokenPresent]"
            if ($tokenNotProvided -and $gitHubTokenPresent) {
                $authType = 'Token'
                $Token = $gitHubToken
            }
        }

        $contextData = @{
            ApiBaseUri = $ApiBaseUri
            ApiVersion = $ApiVersion
            HostName   = $HostName
            AuthType   = $authType
            Enterprise = $Enterprise
            Owner      = $Owner
            Repo       = $Repo
        }

        Write-Verbose ($contextData | Format-Table | Out-String)

        switch ($authType) {
            'UAT' {
                Write-Verbose 'Logging in using device flow...'
                if (-not [string]::IsNullOrEmpty($ClientID)) {
                    Write-Verbose "Using provided ClientID: [$ClientID]"
                    $authClientID = $ClientID
                } else {
                    Write-Verbose "Using default ClientID: [$($gitHubConfig."Default$Mode`ClientID")]"
                    $authClientID = $($gitHubConfig."Default$Mode`ClientID")
                }

                Write-Verbose "Using $Mode authentication..."
                $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $authClientID -Scope $Scope -HostName $HostName

                switch ($Mode) {
                    'GitHubApp' {
                        $contextData += @{
                            Token                      = ConvertTo-SecureString -AsPlainText $tokenResponse.access_token
                            TokenExpirationDate        = (Get-Date).AddSeconds($tokenResponse.expires_in)
                            TokenType                  = $tokenResponse.access_token -replace $script:Auth.TokenPrefixPattern
                            AuthClientID               = $authClientID
                            DeviceFlowType             = $Mode
                            RefreshToken               = ConvertTo-SecureString -AsPlainText $tokenResponse.refresh_token
                            RefreshTokenExpirationDate = (Get-Date).AddSeconds($tokenResponse.refresh_token_expires_in)
                            Scope                      = $tokenResponse.scope
                        }
                    }
                    'OAuthApp' {
                        $contextData += @{
                            Token          = ConvertTo-SecureString -AsPlainText $tokenResponse.access_token
                            TokenType      = $tokenResponse.access_token -replace $script:Auth.TokenPrefixPattern
                            AuthClientID   = $authClientID
                            DeviceFlowType = $Mode
                            Scope          = $tokenResponse.scope
                        }
                    }
                    default {
                        Write-Host '⚠ ' -ForegroundColor Yellow -NoNewline
                        Write-Host "Unexpected authentication mode: $Mode"
                        return
                    }
                }
            }
            'App' {
                Write-Verbose 'Logging in as a GitHub App...'
                $contextData += @{
                    Token     = ConvertTo-SecureString -AsPlainText $PrivateKey
                    TokenType = 'PEM'
                    ClientID  = $ClientID
                }
            }
            'PAT' {
                Write-Debug "UseAccessToken is set to [$UseAccessToken]. Using provided access token..."
                Write-Verbose 'Logging in using personal access token...'
                Write-Host '! ' -ForegroundColor DarkYellow -NoNewline
                Start-Process "https://$HostName/settings/tokens"
                $accessTokenValue = Read-Host -Prompt 'Enter your personal access token' -AsSecureString
                $Token = ConvertFrom-SecureString $accessTokenValue -AsPlainText
                $tokenType = $Token -replace $script:Auth.TokenPrefixPattern
                $contextData += @{
                    Token     = ConvertTo-SecureString -AsPlainText $Token
                    TokenType = $tokenType
                }
            }
            'Token' {
                $tokenType = $Token -replace $script:Auth.TokenPrefixPattern
                switch -Regex ($tokenType) {
                    'ghp|github_pat' {
                        $contextData += @{
                            Token     = ConvertTo-SecureString -AsPlainText $Token
                            TokenType = $tokenType
                        }
                        $contextData['AuthType'] = 'PAT'
                    }
                    'ghs' {
                        Write-Verbose 'Logging in using an installation access token...'
                        $contextData += @{
                            Token     = ConvertTo-SecureString -AsPlainText $Token
                            TokenType = $tokenType
                        }
                        $contextData['AuthType'] = 'IAT'
                    }
                    default {
                        Write-Host '⚠ ' -ForegroundColor Yellow -NoNewline
                        Write-Host "Unexpected token type: $tokenType"
                        throw "Unexpected token type: $tokenType"
                    }
                }
            }
        }
        $contextDataReturn = Set-GitHubContext @contextData -Default:(!$NotDefault) -PassThru
        Write-Verbose ($contextDataReturn | Format-List | Out-String)
        if (-not $Silent) {
            $name = $contextDataReturn.Username
            Write-Host '✓ ' -ForegroundColor Green -NoNewline
            Write-Host "Logged in as $name!"
        }
    } catch {
        Write-Error $_
        Write-Error (Get-PSCallStack | Format-Table | Out-String)
        throw 'Failed to connect to GitHub.'
    } finally {
        Remove-Variable -Name tokenResponse -ErrorAction SilentlyContinue
        Remove-Variable -Name context -ErrorAction SilentlyContinue
        Remove-Variable -Name Token -ErrorAction SilentlyContinue
        [System.GC]::Collect()
    }
    Write-Verbose "[$commandName] - End"
}
