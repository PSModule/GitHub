function Connect-GitHubAccount {
    <#
        .SYNOPSIS
        Connects to GitHub using a personal access token or device code login.

        .DESCRIPTION
        Connects to GitHub using a personal access token or device code login.

        For device flow / device code login:
        PowerShell requests device and user verification codes and gets the authorization URL where you will enter the user verification code.
        In GitHub you will be asked to enter a user verification code at https://github.com/login/device.
        PowerShell will keep polling GitHub for the user authentication status. Once you have authorized the device,
        the app will be able to make API calls with a new access token.

        .EXAMPLE
        Connect-GitHubAccount

        Connects to GitHub using a device flow login.
        If the user has already logged in, the access token will be refreshed.

        .EXAMPLE
        Connect-GitHubAccount -AccessToken
        ! Enter your personal access token: *************

        User gets prompted for the access token and stores it in the secret store.
        The token is used when connecting to GitHub.

        .EXAMPLE
        Connect-GitHubAccount -Mode 'OAuthApp' -Scope 'gist read:org repo workflow'

        Connects to GitHub using a device flow login and sets the scope of the access token.

        .NOTES
        https://docs.github.com/en/rest/overview/other-authentication-methods#authenticating-for-saml-sso
    #>
    [Alias('Connect-GHAccount')]
    [Alias('Connect-GitHub')]
    [Alias('Connect-GH')]
    [Alias('Login-GitHubAccount')]
    [Alias('Login-GHAccount')]
    [Alias('Login-GitHub')]
    [Alias('Login-GH')]
    [OutputType([void])]
    [CmdletBinding(DefaultParameterSetName = 'DeviceFlow')]
    param (
        # Choose between authentication methods, either OAuthApp or GitHubApp.
        # For more info about the types of authentication visit:
        # https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/differences-between-github-apps-and-oauth-apps
        [Parameter(ParameterSetName = 'DeviceFlow')]
        [ValidateSet('OAuthApp', 'GitHubApp')]
        [string] $Mode = 'GitHubApp',

        # The scope of the access token, when using OAuth authentication.
        # Provide the list of scopes as space-separated values.
        # For more information on scopes visit:
        # https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps
        [Parameter(ParameterSetName = 'DeviceFlow')]
        [string] $Scope = 'gist read:org repo workflow',

        # The personal access token to use for authentication.
        [Parameter(
            Mandatory,
            ParameterSetName = 'PAT'
        )]
        [switch] $AccessToken
    )

    $envVar = Get-ChildItem -Path 'Env:' | Where-Object Name -In 'GH_TOKEN', 'GITHUB_TOKEN' | Select-Object -First 1
    $envVarPresent = $envVar.count -gt 0
    $AuthType = $envVarPresent ? 'sPAT' : $PSCmdlet.ParameterSetName

    switch ($AuthType) {
        'DeviceFlow' {
            Write-Verbose 'Logging in using device flow...'
            $clientID = $script:Auth.$Mode.ClientID
            if ($Mode -ne $script:Config.DeviceFlowType) {
                Write-Verbose "Using $Mode authentication..."
                $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $clientID -Scope $Scope
            } else {
                $accessTokenValidity = [datetime]$script:Config.AccessTokenExpirationDate - (Get-Date)
                $accessTokenIsValid = $accessTokenValidity.Seconds -gt 0
                $accessTokenValidityText = "$($accessTokenValidity.Hours):$($accessTokenValidity.Minutes):$($accessTokenValidity.Seconds)"
                if ($accessTokenIsValid) {
                    if ($accessTokenValidity -gt 4) {
                        Write-Host '✓ ' -ForegroundColor Green -NoNewline
                        Write-Host "Access token is still valid for $accessTokenValidityText ..."
                        return
                    } else {
                        Write-Host '⚠ ' -ForegroundColor Yellow -NoNewline
                        Write-Host "Access token remaining validity $accessTokenValidityText. Refreshing access token..."
                        $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $clientID -RefreshToken $script:Config.RefreshToken
                    }
                } else {
                    $refreshTokenValidity = [datetime]$script:Config.RefreshTokenExpirationDate - (Get-Date)
                    $refreshTokenIsValid = $refreshTokenValidity.Seconds -gt 0
                    if ($refreshTokenIsValid) {
                        Write-Host '⚠ ' -ForegroundColor Yellow -NoNewline
                        Write-Verbose 'Access token expired. Refreshing access token...'
                        $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $clientID -RefreshToken $script:Config.RefreshToken
                    } else {
                        Write-Verbose "Using $Mode authentication..."
                        $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $clientID -Scope $Scope
                    }
                }
            }
            Reset-GitHubConfig -Scope 'Auth'
            $script:Config.DeviceFlowType = $Mode
            $script:AuthType = $AuthType
            $script:AccessTokenType = $tokenResponse.access_token -replace '_.*$', '_*'
            $script:Config.AccessToken = ConvertTo-SecureString -AsPlainText $tokenResponse.access_token
            $script:Config.AccessTokenExpirationDate = (Get-Date).AddSeconds($tokenResponse.expires_in)
            $script:Config.RefreshToken = ConvertTo-SecureString -AsPlainText $tokenResponse.refresh_token
            $script:Config.RefreshTokenExpirationDate = (Get-Date).AddSeconds($tokenResponse.refresh_token_expires_in)
            break
        }
        'PAT' {
            Write-Verbose 'Logging in using personal access token...'
            Reset-GitHubConfig -Scope 'Auth'
            $script:Config.AuthType = $AuthType
            Write-Host '! ' -ForegroundColor DarkYellow -NoNewline
            $script:Config.AccessToken = Read-Host -Prompt 'Enter your personal access token' -AsSecureString
            $prefix = (ConvertFrom-SecureString $script:Config.AccessToken -AsPlainText) -replace '_.*$', '_*'
            $script:AccessTokenType = $prefix
            if ($prefix -notmatch '^ghp_|^github_pat_') {
                Write-Host '⚠ ' -ForegroundColor Yellow -NoNewline
                Write-Host "Unexpected access token format: $prefix"
            }
            break
        }
        'sPAT' {
            Write-Verbose 'Logging in using system access token...'
            Reset-GitHubConfig -Scope 'Auth'
            $script:AuthType = 'sPAT'
            $script:Config.AccessToken = ConvertTo-SecureString -AsPlainText $envVar.Value
            $prefix = $envVar.Value -replace '_.*$', '_*'
            $script:AccessTokenType = $prefix
        }
    }

    Save-GitHubConfig
    Write-Host '✓ ' -ForegroundColor Green -NoNewline
    Write-Host 'Logged in to GitHub!'
}
