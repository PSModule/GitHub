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
        Connect-GitHubAccount -UseAccessToken
        ! Enter your personal access token: *************

        User gets prompted for the access token and stores it in the context.
        The token is used when connecting to GitHub.

        .EXAMPLE
        Connect-GitHubAccount -Mode 'OAuthApp' -Scope 'gist read:org repo workflow'

        Connects to GitHub using a device flow login and sets the scope of the access token.

        .NOTES
        [Authenticating to the REST API](https://docs.github.com/rest/overview/other-authentication-methods#authenticating-for-saml-sso)

        .LINK
        https://psmodule.io/GitHub/Functions/Auth/Connect-GitHubAccount
    #>
    [Alias('Connect-GitHub')]
    [OutputType([void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'Long links for documentation.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '',
        Justification = 'Is the CLI part of the module.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'The tokens are received as clear text. Mitigating exposure by removing variables and performing garbage collection.'
    )]
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
        [Parameter(Mandatory, ParameterSetName = 'PAT')]
        [switch] $UseAccessToken,

        # An access token to use for authentication. Can be both a string or a SecureString.
        # Supports both personal access tokens (PAT) and GitHub App installation access tokens (IAT).
        # Example: 'ghp_1234567890abcdef'
        # Example: 'ghs_1234567890abcdef'
        [Parameter(Mandatory, ParameterSetName = 'Token')]
        [object] $Token,

        # The client ID for the GitHub App to use for authentication.
        [Parameter(ParameterSetName = 'UAT')]
        [Parameter(Mandatory, ParameterSetName = 'GitHub App using a PrivateKey')]
        [Parameter(Mandatory, ParameterSetName = 'GitHub App using a KeyVault Key Reference')]
        [string] $ClientID,

        # The private key that is used to sign JWTs for the GitHub App.
        [Parameter(Mandatory, ParameterSetName = 'GitHub App using a PrivateKey')]
        [object] $PrivateKey,

        # The KeyVault Key Reference that can sign JWTs for the GitHub App.
        [Parameter(Mandatory, ParameterSetName = 'GitHub App using a KeyVault Key Reference')]
        [ValidateScript({
                if ($_ -notlike 'https://*.vault.azure.net/keys/*') {
                    throw "Invalid Key Vault key reference format: $_"
                }
                return $true
            })]
        [string] $KeyVaultKeyReference,

        # Automatically load installations for the GitHub App.
        [Parameter(ParameterSetName = 'GitHub App using a PrivateKey')]
        [Parameter(ParameterSetName = 'GitHub App using a KeyVault Key Reference')]
        [switch] $AutoloadInstallations,

        # The default enterprise to use in commands.
        [Parameter()]
        [string] $Enterprise,

        # Set the default owner to use in commands.
        [Parameter()]
        [Alias('Organization')]
        [string] $Owner,

        # Set the default repository to use in commands.
        [Parameter()]
        [string] $Repository,

        # The host to connect to. Can use $env:GITHUB_SERVER_URL to set the host, as the protocol is removed automatically.
        # Example: github.com, github.enterprise.com, msx.ghe.com
        [Parameter()]
        [Alias('Host')]
        [Alias('Server')]
        [string] $HostName,

        # Suppresses the output of the function.
        [Parameter()]
        [Alias('Quiet')]
        [switch] $Silent,

        # Make the connected context NOT the default context.
        [Parameter()]
        [switch] $NotDefault,

        # Passes the context object to the pipeline.
        [Parameter()]
        [switch] $PassThru
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Initialize-GitHubConfig
    }

    process {
        try {
            if ($Token -is [System.Security.SecureString]) {
                $Token = ConvertFrom-SecureString $Token -AsPlainText
            }

            if (-not $HostName) {
                $HostName = $script:GitHub.Config.HostName
            }
            $httpVersion = $script:GitHub.Config.HttpVersion
            $perPage = $script:GitHub.Config.PerPage
            $ApiVersion = $script:GitHub.Config.ApiVersion
            $HostName = $HostName -replace '^https?://'
            $ApiBaseUri = "https://api.$HostName"

            # If running on GitHub Actions and no access token is provided, use the GitHub token.
            if ($script:IsGitHubActions -and $PSCmdlet.ParameterSetName -notin @('GitHub App using a PrivateKey', 'GitHub App using a KeyVault Key Reference')) {
                $customTokenProvided = -not [string]::IsNullOrEmpty($Token)
                $gitHubTokenPresent = Test-GitHubToken
                Write-Verbose "A token was provided:  [$customTokenProvided]"
                Write-Verbose "Detected GitHub token: [$gitHubTokenPresent]"
                $usingGitHubToken = $gitHubTokenPresent -and -not $customTokenProvided
                if ($usingGitHubToken) {
                    $authType = 'Token'
                    $Token = Get-GitHubToken
                }
            }

            $context = @{
                ApiBaseUri  = [string]$ApiBaseUri
                ApiVersion  = [string]$ApiVersion
                HostName    = [string]$HostName
                HttpVersion = [string]$httpVersion
                PerPage     = [int]$perPage
                Enterprise  = [string]$Enterprise
                Owner       = [string]$Owner
                Repository  = [string]$Repository
            }

            $context | Format-Table | Out-String -Stream | ForEach-Object { Write-Verbose $_ }

            switch ($PSCmdlet.ParameterSetName) {
                'UAT' {
                    Write-Verbose 'Logging in using device flow...'
                    if (-not [string]::IsNullOrEmpty($ClientID)) {
                        Write-Verbose "Using provided ClientID: [$ClientID]"
                        $authClientID = $ClientID
                    } else {
                        switch ($Mode) {
                            'GitHubApp' {
                                Write-Verbose "Using default ClientID: [$($script:GitHub.Config.GitHubAppClientID)]"
                                $authClientID = $($script:GitHub.Config.GitHubAppClientID)
                            }
                            'OAuthApp' {
                                Write-Verbose "Using default ClientID: [$($script:GitHub.Config.OAuthAppClientID)]"
                                $authClientID = $($script:GitHub.Config.OAuthAppClientID)
                            }
                            default {
                                Write-Warning '⚠ ' -ForegroundColor Yellow -NoNewline
                                Write-Warning "Unexpected authentication mode: $Mode"
                                return
                            }
                        }
                    }
                    Write-Verbose "Using $Mode authentication..."
                    $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $authClientID -Scope $Scope -HostName $HostName

                    switch ($Mode) {
                        'GitHubApp' {
                            $context += @{
                                AuthType              = 'UAT'
                                Token                 = ConvertTo-SecureString -AsPlainText $tokenResponse.access_token
                                TokenExpiresAt        = ([DateTime]::Now).AddSeconds($tokenResponse.expires_in)
                                TokenType             = $tokenResponse.access_token -replace $script:GitHub.TokenPrefixPattern
                                AuthClientID          = $authClientID
                                DeviceFlowType        = $Mode
                                RefreshToken          = ConvertTo-SecureString -AsPlainText $tokenResponse.refresh_token
                                RefreshTokenExpiresAt = ([DateTime]::Now).AddSeconds($tokenResponse.refresh_token_expires_in)
                                Scope                 = $tokenResponse.scope
                            }
                        }
                        'OAuthApp' {
                            $context += @{
                                AuthType       = 'UAT'
                                Token          = ConvertTo-SecureString -AsPlainText $tokenResponse.access_token
                                TokenType      = $tokenResponse.access_token -replace $script:GitHub.TokenPrefixPattern
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
                'GitHub App using a PrivateKey' {
                    Write-Verbose 'Logging in as a GitHub App using PrivateKey...'
                    if (-not($PrivateKey -is [System.Security.SecureString])) {
                        $PrivateKey = $PrivateKey | ConvertTo-SecureString -AsPlainText
                    }
                    $context += @{
                        AuthType   = 'APP'
                        PrivateKey = $PrivateKey
                        TokenType  = 'JWT'
                        ClientID   = $ClientID
                    }
                }
                'GitHub App using a KeyVault Key Reference' {
                    Write-Verbose 'Logging in as a GitHub App using KeyVault Key Reference...'
                    $context += @{
                        AuthType             = 'APP'
                        KeyVaultKeyReference = $KeyVaultKeyReference
                        TokenType            = 'JWT'
                        ClientID             = $ClientID
                    }
                }
                'PAT' {
                    Write-Debug "UseAccessToken is set to [$UseAccessToken]. Using provided access token..."
                    Write-Verbose 'Logging in using personal access token...'
                    Write-Host '! ' -ForegroundColor DarkYellow -NoNewline
                    Start-Process "https://$HostName/settings/tokens"
                    $accessTokenValue = Read-Host -Prompt 'Enter your personal access token' -AsSecureString
                    $Token = ConvertFrom-SecureString $accessTokenValue -AsPlainText
                    $tokenType = $Token -replace $script:GitHub.TokenPrefixPattern
                    $context += @{
                        AuthType  = 'PAT'
                        Token     = ConvertTo-SecureString -AsPlainText $Token
                        TokenType = $tokenType
                    }
                }
                'Token' {
                    $tokenType = $Token -replace $script:GitHub.TokenPrefixPattern
                    switch -Regex ($tokenType) {
                        'ghp|github_pat' {
                            Write-Verbose 'Logging in using a user access token...'
                            $context += @{
                                Token     = ConvertTo-SecureString -AsPlainText $Token
                                TokenType = $tokenType
                            }
                            $context['AuthType'] = 'PAT'
                        }
                        'ghs' {
                            Write-Verbose 'Logging in using an installation access token...'
                            $context += @{
                                Token     = ConvertTo-SecureString -AsPlainText $Token
                                TokenType = $tokenType
                            }
                            $context['AuthType'] = 'IAT'
                        }
                        default {
                            Write-Host '⚠ ' -ForegroundColor Yellow -NoNewline
                            Write-Host "Unexpected token type: $tokenType"
                            throw "Unexpected token type: $tokenType"
                        }
                    }
                }
                default {}
            }
            $contextObj = Set-GitHubContext -Context $context -Default:(!$NotDefault) -PassThru
            $contextObj | Format-List | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
            if (-not $Silent) {
                $name = $contextObj.Username
                if ($script:IsGitHubActions) {
                    $green = $PSStyle.Foreground.Green
                    $reset = $PSStyle.Reset
                    Write-Host "$green✓$reset Logged in as $name!"
                } else {
                    Write-Host '✓ ' -ForegroundColor Green -NoNewline
                    Write-Host "Logged in as $name!"
                }
            }
            if ($PassThru) {
                Write-Debug "Passing context [$contextObj] to the pipeline."
                $contextObj
            }

            if ($authType -eq 'App' -and $AutoloadInstallations) {
                Write-Verbose 'Loading GitHub App Installation contexts...'
                Connect-GitHubApp -Silent:$Silent
            }

        } catch {
            Write-Error $_
            Write-Error (Get-PSCallStack | Format-Table | Out-String)
            throw 'Failed to connect to GitHub.'
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
