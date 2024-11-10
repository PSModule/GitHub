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

        User gets prompted for the access token and stores it in the secret store.
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
    param (
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

        # An access token to use for authentication.
        # Supports both personal access tokens (PAT) and GitHub App installation access tokens (IAT).
        # Example: 'ghp_1234567890abcdef'
        # Example: 'ghs_1234567890abcdef'
        [Parameter(
            Mandatory,
            ParameterSetName = 'Token'
        )]
        [string] $Token,

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
        [string] $HostName = $env:GITHUB_SERVER_URL ?? 'github.com',

        # Suppresses the output of the function.
        [Parameter()]
        [Alias('Quiet')]
        [Alias('q')]
        [Alias('s')]
        [switch] $Silent
    )
    try {
        $HostName = $HostName -replace '^https?://'
        $ApiBaseUri = "https://api.$HostName"
        $authType = $PSCmdlet.ParameterSetName

        # If running on GitHub Actions and no access token is provided, use the GitHub token.
        if ($env:GITHUB_ACTIONS -eq 'true') {
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

        $context = @{
            Name       = 'default'
            ApiBaseUri = $ApiBaseUri
            ApiVersion = $ApiVersion
            HostName   = $HostName
            AuthType   = $authType
            Owner      = $Owner
            Repo       = $Repo
        }

        Write-Verbose "AuthType: [$authType]"
        switch ($authType) {
            'UAT' {
                Write-Verbose 'Logging in using device flow...'
                if (-not [string]::IsNullOrEmpty($ClientID)) {
                    Write-Verbose "Using provided ClientID: [$ClientID]"
                    $authClientID = $ClientID
                } elseif (-not [string]::IsNullOrEmpty($(Get-GitHubConfig -Name 'AuthClientID'))) {
                    Write-Verbose "Reusing previously stored ClientID: [$(Get-GitHubConfig -Name 'AuthClientID')]"
                    $authClientID = Get-GitHubConfig -Name 'AuthClientID'
                } else {
                    Write-Verbose "Using default ClientID: [$($script:Auth.$Mode.ClientID)]"
                    $authClientID = $script:Auth.$Mode.ClientID
                }
                if ($Mode -ne (Get-GitHubConfig -Name 'DeviceFlowType' -ErrorAction SilentlyContinue)) {
                    Write-Verbose "Using $Mode authentication..."
                    $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $authClientID -Scope $Scope -HostName $HostName
                } else {
                    $accessTokenValidity = [datetime](Get-GitHubConfig -Name 'SecretExpirationDate') - (Get-Date)
                    $accessTokenIsValid = $accessTokenValidity.Seconds -gt 0
                    $hours = $accessTokenValidity.Hours.ToString().PadLeft(2, '0')
                    $minutes = $accessTokenValidity.Minutes.ToString().PadLeft(2, '0')
                    $seconds = $accessTokenValidity.Seconds.ToString().PadLeft(2, '0')
                    $accessTokenValidityText = "$hours`:$minutes`:$seconds"
                    if ($accessTokenIsValid) {
                        if ($accessTokenValidity.TotalHours -gt $script:Auth.AccessTokenGracePeriodInHours) {
                            if (-not $Silent) {
                                Write-Host '✓ ' -ForegroundColor Green -NoNewline
                                Write-Host "Access token is still valid for $accessTokenValidityText ..."
                            }
                            break
                        } else {
                            if (-not $Silent) {
                                Write-Host '⚠ ' -ForegroundColor Yellow -NoNewline
                                Write-Host "Access token remaining validity $accessTokenValidityText. Refreshing access token..."
                            }
                            $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $authClientID -RefreshToken (Get-GitHubConfig -Name 'RefreshToken') -HostName $HostName
                        }
                    } else {
                        $refreshTokenValidity = [datetime](Get-GitHubConfig -Name 'RefreshTokenExpirationDate') - (Get-Date)
                        $refreshTokenIsValid = $refreshTokenValidity.Seconds -gt 0
                        if ($refreshTokenIsValid) {
                            if (-not $Silent) {
                                Write-Host '⚠ ' -ForegroundColor Yellow -NoNewline
                                Write-Host 'Access token expired. Refreshing access token...'
                            }
                            $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $authClientID -RefreshToken (Get-GitHubConfig -Name 'RefreshToken') -HostName $HostName
                        } else {
                            Write-Verbose "Using $Mode authentication..."
                            $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $authClientID -Scope $Scope -HostName $HostName
                        }
                    }
                }
                switch ($Mode) {
                    'GitHubApp' {
                        $context += @{
                            Secret                     = ConvertTo-SecureString -AsPlainText $tokenResponse.access_token
                            SecretExpirationDate       = (Get-Date).AddSeconds($tokenResponse.expires_in)
                            SecretType                 = $tokenResponse.access_token -replace '_[^_]+$'
                            AuthClientID               = $authClientID
                            DeviceFlowType             = $Mode
                            RefreshToken               = ConvertTo-SecureString -AsPlainText $tokenResponse.refresh_token
                            RefreshTokenExpirationDate = (Get-Date).AddSeconds($tokenResponse.refresh_token_expires_in)
                            Scope                      = $tokenResponse.scope
                        }
                    }
                    'OAuthApp' {
                        $context += @{
                            Secret         = ConvertTo-SecureString -AsPlainText $tokenResponse.access_token
                            SecretType     = $tokenResponse.access_token -replace '_[^_]+$'
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
                $context += @{
                    Secret     = ConvertTo-SecureString -AsPlainText $PrivateKey
                    SecretType = 'PEM'
                    ClientID   = $ClientID
                }
            }
            'PAT' {
                Write-Debug "UseAccessToken is set to [$UseAccessToken]. Using provided access token..."
                Write-Verbose 'Logging in using personal access token...'
                Write-Host '! ' -ForegroundColor DarkYellow -NoNewline
                Start-Process "https://$HostName/settings/tokens"
                $accessTokenValue = Read-Host -Prompt 'Enter your personal access token' -AsSecureString
                $Token = ConvertFrom-SecureString $accessTokenValue -AsPlainText
                $secretType = $Token -replace '_[^_]+$'
                $context += @{
                    Secret     = ConvertTo-SecureString -AsPlainText $Token
                    SecretType = $secretType
                }
            }
            'Token' {
                $secretType = $Token -replace '_[^_]+$'
                switch -Regex ($secretType) {
                    'ghp|github_pat' {
                        $context += @{
                            Secret     = ConvertTo-SecureString -AsPlainText $Token
                            SecretType = $secretType
                        }
                        $context['AuthType'] = 'PAT'
                    }
                    'ghs' {
                        Write-Verbose 'Logging in using an installation access token...'
                        $context += @{
                            Secret     = ConvertTo-SecureString -AsPlainText $Token
                            SecretType = $secretType
                        }
                        $context['Name'] = 'system'
                        $context['AuthType'] = 'IAT'
                    }
                    default {
                        Write-Host '⚠ ' -ForegroundColor Yellow -NoNewline
                        Write-Host "Unexpected token type: $secretType"
                        throw "Unexpected token type: $secretType"
                    }
                }
            }
        }
        Write-Verbose ($context | Format-Table | Out-String)
        Set-GitHubContext @context
        try {
            $username = switch ($context['AuthType']) {
                'PAT' {
                    $user = Get-GitHubUser
                    $username = $user.login
                }
                'UAT' {
                    $user = Get-GitHubUser
                    $username = $user.login
                }
                'IAT' {
                    'installation'
                }
                'App' {
                    $app = Get-GitHubApp
                    $app.slug
                }
                default {
                    'unknown'
                }
            }
            $context = Get-GitHubContext
            $context['Name'] = $username
            Set-GitHubContext @context
        } catch {
            Write-Verbose ($_ | Out-String)
            Write-Verbose 'Failed to set the user name'
        }

        if (-not $Silent) {
            $name = $(Get-GitHubConfig -Name Name)
            Write-Host '✓ ' -ForegroundColor Green -NoNewline
            Write-Host "Logged in as $name!"
        }
    } catch {
        throw $_
    } finally {
        Remove-Variable -Name tokenResponse -ErrorAction SilentlyContinue
        Remove-Variable -Name context -ErrorAction SilentlyContinue
        [System.GC]::Collect()
    }
}
