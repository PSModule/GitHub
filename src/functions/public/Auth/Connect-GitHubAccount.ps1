﻿function Connect-GitHubAccount {
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
        Connect-GitHubAccount -AccessToken
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'AccessToken', Justification = 'Required for parameter set')]
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

        # The personal access token to use for authentication.
        [Parameter(
            Mandatory,
            ParameterSetName = 'PAT'
        )]
        [Alias('Token')]
        [Alias('PAT')]
        [switch] $AccessToken,
        

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
        [string] $Owner,

        # Set the default repository to use in commands.
        [Parameter()]
        [Alias('Repository')]
        [string] $Repo,

        # API version used for API requests.
        [Parameter()]
        [string] $ApiVersion = '2022-11-28',

        # The host to connect to. Can use $env:GITHUB_SERVER_URL to set the host, as the protocol is removed automatically.
        # Example: github.com, github.enterprise.com, msx.ghe.com
        [Parameter()]
        [Alias('Host')]
        [Alias('Server')]
        [string] $HostName = 'github.com',

        # Suppresses the output of the function.
        [Parameter()]
        [Alias('Quiet')]
        [Alias('q')]
        [Alias('s')]
        [switch] $Silent
    )

    $HostName = $HostName -replace '^https?://'
    $ApiBaseUri = "https://api.$HostName"

    $envVars = Get-ChildItem -Path 'Env:'
    Write-Debug 'Environment variables:'
    Write-Debug ($envVars | Format-Table -AutoSize | Out-String)
    $gitHubToken = $envVars | Where-Object Name -In 'GH_TOKEN', 'GITHUB_TOKEN' | Select-Object -First 1 -ExpandProperty Value
    Write-Debug "GitHub token: [$gitHubToken]"
    $gitHubTokenPresent = $gitHubToken.count -gt 0 -and -not [string]::IsNullOrEmpty($gitHubToken)
    Write-Debug "GitHub token present: [$gitHubTokenPresent]"
    $AuthType = if ($gitHubTokenPresent) { 'IAT' } else { $PSCmdlet.ParameterSetName }
    Write-Verbose "AuthType: [$AuthType]"
    switch ($AuthType) {
        'UAT' {
            Write-Verbose 'Logging in using device flow...'
            $authClientID = $ClientID ?? (Get-GitHubConfig -Name 'AuthClientID') ?? $script:Auth.$Mode.ClientID
            if ($Mode -ne (Get-GitHubConfig -Name 'DeviceFlowType' -ErrorAction SilentlyContinue)) {
                Write-Verbose "Using $Mode authentication..."
                $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $authClientID -Scope $Scope -HostName $HostName
            } else {
                $accessTokenValidity = [datetime](Get-GitHubConfig -Name 'AccessTokenExpirationDate') - (Get-Date)
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
            Reset-GitHubConfig -Scope 'Auth'
            switch ($Mode) {
                'GitHubApp' {
                    $settings = @{
                        AccessToken                = ConvertTo-SecureString -AsPlainText $tokenResponse.access_token
                        AccessTokenExpirationDate  = (Get-Date).AddSeconds($tokenResponse.expires_in)
                        AccessTokenType            = $tokenResponse.access_token -replace '_.*$', '_*'
                        ApiBaseUri                 = $ApiBaseUri
                        ApiVersion                 = $ApiVersion
                        AuthClientID               = $authClientID
                        AuthType                   = $AuthType
                        DeviceFlowType             = $Mode
                        HostName                   = $HostName
                        RefreshToken               = ConvertTo-SecureString -AsPlainText $tokenResponse.refresh_token
                        RefreshTokenExpirationDate = (Get-Date).AddSeconds($tokenResponse.refresh_token_expires_in)
                        Scope                      = $tokenResponse.scope
                    }
                }
                'OAuthApp' {
                    $settings = @{
                        AccessToken     = ConvertTo-SecureString -AsPlainText $tokenResponse.access_token
                        AccessTokenType = $tokenResponse.access_token -replace '_.*$', '_*'
                        ApiBaseUri      = $ApiBaseUri
                        ApiVersion      = $ApiVersion
                        AuthClientID    = $authClientID
                        AuthType        = $AuthType
                        DeviceFlowType  = $Mode
                        HostName        = $HostName
                        Scope           = $tokenResponse.scope
                    }
                }
            }
            Set-GitHubConfig @settings
            break
        }
        'PAT' {
            Write-Verbose 'Logging in using personal access token...'
            Reset-GitHubConfig -Scope 'Auth'
            Write-Host '! ' -ForegroundColor DarkYellow -NoNewline
            Start-Process "https://$HostName/settings/tokens"
            $accessTokenValue = Read-Host -Prompt 'Enter your personal access token' -AsSecureString
            $accessTokenType = (ConvertFrom-SecureString $accessTokenValue -AsPlainText) -replace '_.*$', '_*'
            if ($accessTokenType -notmatch '^ghp_|^github_pat_') {
                Write-Host '⚠ ' -ForegroundColor Yellow -NoNewline
                Write-Host "Unexpected access token format: $accessTokenType"
            }
            $settings = @{
                AccessToken     = $accessTokenValue
                AccessTokenType = $accessTokenType
                ApiBaseUri      = $ApiBaseUri
                ApiVersion      = $ApiVersion
                AuthType        = $AuthType
                HostName        = $HostName
            }
            Set-GitHubConfig @settings
            break
        }
        'App' {
            Write-Verbose 'Logging in as a GitHub App...'
            Reset-GitHubConfig -Scope 'Auth'
            $jwt = Get-GitHubAppJWT -ClientId $ClientID -PrivateKey $PrivateKey
            $settings = @{
                AccessToken     = ConvertTo-SecureString -AsPlainText $jwt
                AccessTokenType = 'JWT'
                ApiBaseUri      = $ApiBaseUri
                ApiVersion      = $ApiVersion
                AuthType        = $AuthType
                ClientID        = $ClientID
                HostName        = $HostName
            }
            Set-GitHubConfig @settings
        }
        'IAT' {
            Write-Verbose 'Logging in using GitHub access token...'
            Reset-GitHubConfig -Scope 'Auth'
            $prefix = $gitHubToken -replace '_.*$', '_*'
            $settings = @{
                AccessToken     = ConvertTo-SecureString -AsPlainText $gitHubToken
                AccessTokenType = $prefix
                ApiBaseUri      = $ApiBaseUri
                ApiVersion      = $ApiVersion
                AuthType        = 'IAT'
                ClientID        = $ClientID
                HostName        = $HostName
            }
            Set-GitHubConfig @settings
        }
    }

    switch ($AuthType) {
        'App' {
            $app = Get-GitHubApp
            $username = $app.slug
        }
        'IAT' {
            Get-GitHubApp
            $username = 'system'
        }
        default {
            $user = Get-GitHubUser
            $username = $user.login
        }
    }

    if (-not $Silent) {
        Write-Host '✓ ' -ForegroundColor Green -NoNewline
        Write-Host "Logged in as $username!"
    }

    if ($Owner) {
        Set-GitHubConfig -Owner $Owner
    }

    if ($Repo) {
        Set-GitHubConfig -Repo $Repo
    }

    Remove-Variable -Name tokenResponse -ErrorAction SilentlyContinue
    Remove-Variable -Name settings -ErrorAction SilentlyContinue
    [System.GC]::Collect()

}
