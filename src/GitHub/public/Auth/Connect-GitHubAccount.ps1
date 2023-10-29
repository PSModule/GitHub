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
        https://docs.github.com/rest/overview/other-authentication-methods#authenticating-for-saml-sso
    #>
    [Alias('Connect-GHAccount')]
    [Alias('Connect-GitHub')]
    [Alias('Connect-GH')]
    [Alias('Login-GitHubAccount')]
    [Alias('Login-GHAccount')]
    [Alias('Login-GitHub')]
    [Alias('Login-GH')]
    [OutputType([void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'AccessToken', Justification = 'Required for parameter set')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Is the CLI part of the module.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        '',
        Justification = 'The tokens are recieved as clear text. Mitigating exposure by removing variables and performing garbage collection.'
    )]
    [CmdletBinding(DefaultParameterSetName = 'DeviceFlow')]
    param (
        # Choose between authentication methods, either OAuthApp or GitHubApp.
        # For more info about the types of authentication visit:
        # https://docs.github.com/apps/oauth-apps/building-oauth-apps/differences-between-github-apps-and-oauth-apps
        [Parameter(ParameterSetName = 'DeviceFlow')]
        [ValidateSet('OAuthApp', 'GitHubApp')]
        [string] $Mode = 'GitHubApp',

        # The scope of the access token, when using OAuth authentication.
        # Provide the list of scopes as space-separated values.
        # For more information on scopes visit:
        # https://docs.github.com/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps
        [Parameter(ParameterSetName = 'DeviceFlow')]
        [string] $Scope = 'gist read:org repo workflow',

        # The personal access token to use for authentication.
        [Parameter(
            Mandatory,
            ParameterSetName = 'PAT'
        )]
        [Alias('Token')]
        [Alias('PAT')]
        [switch] $AccessToken,

        # Set the default owner to use in commands.
        [Parameter()]
        [Alias('Organization')]
        [Alias('Org')]
        [string] $Owner,

        # Set the default repository to use in commands.
        [Parameter()]
        [Alias('Repository')]
        [string] $Repo,

        # Suppresses the output of the function.
        [Parameter()]
        [Alias('Quiet')]
        [Alias('q')]
        [Alias('s')]
        [switch] $Silent
    )

    $envVars = Get-ChildItem -Path 'Env:'
    $systemToken = $envVars | Where-Object Name -In 'GH_TOKEN', 'GITHUB_TOKEN' | Select-Object -First 1
    $systemTokenPresent = $systemToken.count -gt 0
    $AuthType = $systemTokenPresent ? 'sPAT' : $PSCmdlet.ParameterSetName

    switch ($AuthType) {
        'DeviceFlow' {
            Write-Verbose 'Logging in using device flow...'
            $clientID = $script:Auth.$Mode.ClientID
            if ($Mode -ne (Get-GitHubConfig -Name DeviceFlowType -ErrorAction SilentlyContinue)) {
                Write-Verbose "Using $Mode authentication..."
                $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $clientID -Scope $Scope
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
                        $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $clientID -RefreshToken (Get-GitHubConfig -Name RefreshToken)
                    }
                } else {
                    $refreshTokenValidity = [datetime](Get-GitHubConfig -Name 'RefreshTokenExpirationDate') - (Get-Date)
                    $refreshTokenIsValid = $refreshTokenValidity.Seconds -gt 0
                    if ($refreshTokenIsValid) {
                        if (-not $Silent) {
                            Write-Host '⚠ ' -ForegroundColor Yellow -NoNewline
                            Write-Host 'Access token expired. Refreshing access token...'
                        }
                        $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $clientID -RefreshToken (Get-GitHubConfig -Name RefreshToken)
                    } else {
                        Write-Verbose "Using $Mode authentication..."
                        $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $clientID -Scope $Scope
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
                        ApiBaseUri                 = 'https://api.github.com'
                        ApiVersion                 = '2022-11-28'
                        AuthType                   = $AuthType
                        DeviceFlowType             = $Mode
                        RefreshToken               = ConvertTo-SecureString -AsPlainText $tokenResponse.refresh_token
                        RefreshTokenExpirationDate = (Get-Date).AddSeconds($tokenResponse.refresh_token_expires_in)
                        Scope                      = $tokenResponse.scope
                    }
                }
                'OAuthApp' {
                    $settings = @{
                        AccessToken     = ConvertTo-SecureString -AsPlainText $tokenResponse.access_token
                        AccessTokenType = $tokenResponse.access_token -replace '_.*$', '_*'
                        ApiBaseUri      = 'https://api.github.com'
                        ApiVersion      = '2022-11-28'
                        AuthType        = $AuthType
                        DeviceFlowType  = $Mode
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
            Start-Process 'https://github.com/settings/tokens'
            $accessTokenValue = Read-Host -Prompt 'Enter your personal access token' -AsSecureString
            $accessTokenType = (ConvertFrom-SecureString $accessTokenValue -AsPlainText) -replace '_.*$', '_*'
            if ($accessTokenType -notmatch '^ghp_|^github_pat_') {
                Write-Warning '⚠ ' -ForegroundColor Yellow -NoNewline
                Write-Warning "Unexpected access token format: $accessTokenType"
            }
            $settings = @{
                AccessToken     = $accessTokenValue
                AccessTokenType = $accessTokenType
                ApiBaseUri      = 'https://api.github.com'
                ApiVersion      = '2022-11-28'
                AuthType        = $AuthType
            }
            Set-GitHubConfig @settings
            break
        }
        'sPAT' {
            Write-Verbose 'Logging in using system access token...'
            Reset-GitHubConfig -Scope 'Auth'
            $prefix = $systemToken.Value -replace '_.*$', '_*'
            $settings = @{
                AccessToken     = ConvertTo-SecureString -AsPlainText $systemToken.Value
                AccessTokenType = $prefix
                ApiBaseUri      = 'https://api.github.com'
                ApiVersion      = '2022-11-28'
                AuthType        = 'sPAT'
            }
            Set-GitHubConfig @settings
        }
    }

    if ($AuthType -ne 'sPAT') {
        $user = Get-GitHubUser
        $username = $user.login
        Set-GitHubConfig -UserName $username
    } else {
        $username = 'system'
    }

    if (-not $Silent) {
        Write-Host '✓ ' -ForegroundColor Green -NoNewline
        Write-Host "Logged in as $username!"
    }

    $systemRepo = $envVars | Where-Object Name -EQ 'GITHUB_REPOSITORY'
    $systemRepoPresent = $systemRepo.count -gt 0

    if ($Owner) {
        Set-GitHubConfig -Owner $Owner
    } elseif ($systemRepoPresent) {
        $owner = $systemRepo.Value.Split('/')[0]
        Set-GitHubConfig -Owner $owner
    }

    if ($Repo) {
        Set-GitHubConfig -Repo $Repo
    } elseif ($systemRepoPresent) {
        $repo = $systemRepo.Value.Split('/')[-1]
        Set-GitHubConfig -Repo $repo
    }
    
    Remove-Variable -Name tokenResponse -ErrorAction SilentlyContinue
    Remove-Variable -Name settings -ErrorAction SilentlyContinue
    [System.GC]::Collect()

}
