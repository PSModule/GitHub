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

        .EXAMPLE
        Connect-GitHubAccount -AccessToken 'ghp_####'

        Connects to GitHub using a personal access token (PAT).

        .EXAMPLE
        Connect-GitHubAccount -Refresh

        Refreshes the access token.

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
        [string] $Scope,

        # Refresh the access token.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Refresh'
        )]
        [switch] $Refresh,

        # The personal access token to use for authentication.
        [Parameter(
            Mandatory,
            ParameterSetName = 'PAT'
        )]
        [String] $AccessToken
    )

    $vault = Get-SecretVault | Where-Object -Property ModuleName -EQ $script:SecretVault.Type

    if ($null -eq $vault) {
        Initialize-SecretVault -Name $script:SecretVault.Name -Type $script:SecretVault.Type
        $vault = Get-SecretVault | Where-Object -Property ModuleName -EQ $script:SecretVault.Type
    }

    $clientID = $script:App.$Mode.ClientID

    switch ($PSCmdlet.ParameterSetName) {
        'Refresh' {
            Write-Verbose 'Refreshing access token...'
            $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $clientID -RefreshToken $script:Config.User.Auth.RefreshToken.Value
        }
        'DeviceFlow' {
            Write-Verbose 'Logging in using device flow...'
            if ([string]::IsNullOrEmpty($Scope) -and ($Mode -eq 'OAuthApp')) {
                $Scope = 'gist read:org repo workflow'
            }
            $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $clientID -Scope $Scope
            $script:Config.User.Auth.Mode = $Mode
        }
        'PAT' {
            Write-Verbose 'Logging in using personal access token...'
            Reset-GitHubConfig -Scope 'User.Auth'
            $script:Config.User.Auth.AccessToken.Value = $Token
            $script:Config.User.Auth.Mode = 'PAT'
            Save-GitHubConfig
            Write-Host '✓ ' -ForegroundColor Green -NoNewline
            Write-Host 'Logged in using a personal access token (PAT)!'
            return
        }
    }

    if ($tokenResponse) {
        $script:Config.User.Auth.AccessToken.Value = $tokenResponse.access_token
        $script:Config.User.Auth.AccessToken.ExpirationDate = (Get-Date).AddSeconds($tokenResponse.expires_in)
        $script:Config.User.Auth.RefreshToken.Value = $tokenResponse.refresh_token
        $script:Config.User.Auth.RefreshToken.ExpirationDate = (Get-Date).AddSeconds($tokenResponse.refresh_token_expires_in)
        $script:Config.User.Auth.Scope = $tokenResponse.scope
    }

    Save-GitHubConfig

    Write-Host '✓ ' -ForegroundColor Green -NoNewline
    Write-Host "Logged in to GitHub!"
}
