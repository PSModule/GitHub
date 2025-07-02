function Update-GitHubUserAccessToken {
    <#
        .SYNOPSIS
        Updates the GitHub access token.

        .DESCRIPTION
        Updates the GitHub access token. If the access token is still valid, it will not be refreshed.
        Uses a mutex lock based on the Context.ID to prevent concurrent token refresh operations.
        If a mutex lock exists and the token is still valid, returns the existing context.
        If a mutex lock exists but the token is not valid, waits for the mutex to be released.

        .EXAMPLE
        Update-GitHubUserAccessToken

        This will update the GitHub access token for the default context.

        .EXAMPLE
        Update-GitHubUserAccessToken -Context 'github.com/mojombo'

        This will update the GitHub access token for the context 'github.com/mojombo'.

        .NOTES
        [Refreshing user access tokens](https://docs.github.com/apps/creating-github-apps/authenticating-with-a-github-app/refreshing-user-access-tokens)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([securestring])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Is the CLI part of the module.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'The tokens are recieved as clear text. Mitigating exposure by removing variables and performing garbage collection.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Reason for suppressing')]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context,

        # Return the new access token.
        [Parameter()]
        [switch] $PassThru
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType UAT
    }

    process {
        # Check for mutex lock based on Context.ID
        $mutexName = $Context.ID
        $mutex = $null
        $mutexOwned = $false

        try {
            # Try to create or open the mutex
            $mutex = [System.Threading.Mutex]::new($false, $mutexName)

            # Check if another process/thread already owns the mutex
            if (-not $mutex.WaitOne(0)) {
                Write-Verbose "Mutex lock detected for context [$mutexName]"

                # Check if current token is still valid
                $accessTokenValidity = [datetime]($Context.TokenExpirationDate) - (Get-Date)
                $accessTokenIsValid = $accessTokenValidity.Seconds -gt 0

                if ($accessTokenIsValid -and $accessTokenValidity.TotalHours -gt $script:GitHub.Config.AccessTokenGracePeriodInHours) {
                    Write-Verbose 'Token is still valid, returning existing context'
                    if ($PassThru) {
                        return $Context.Token
                    } else {
                        return
                    }
                }

                # Token is not valid, wait for mutex to be released
                Write-Verbose 'Token is not valid, waiting for mutex to be released...'
                do {
                    Start-Sleep -Milliseconds 100
                } while (-not $mutex.WaitOne(0))

                Write-Verbose 'Mutex acquired after waiting'
            }

            $mutexOwned = $true

            # Proceed with the original token validation logic
            Write-Verbose "Reusing previously stored ClientID: [$($Context.AuthClientID)]"
            $authClientID = $Context.AuthClientID
            $accessTokenValidity = [datetime]($Context.TokenExpirationDate) - (Get-Date)
            $accessTokenIsValid = $accessTokenValidity.Seconds -gt 0
            $hours = $accessTokenValidity.Hours.ToString().PadLeft(2, '0')
            $minutes = $accessTokenValidity.Minutes.ToString().PadLeft(2, '0')
            $seconds = $accessTokenValidity.Seconds.ToString().PadLeft(2, '0')
            $accessTokenValidityText = "$hours`:$minutes`:$seconds"
            if ($accessTokenIsValid) {
                if ($accessTokenValidity.TotalHours -gt $script:GitHub.Config.AccessTokenGracePeriodInHours) {
                    if (-not $Silent) {
                        Write-Host '✓ ' -ForegroundColor Green -NoNewline
                        Write-Host "Access token is still valid for $accessTokenValidityText ..."
                    }
                    if ($PassThru) {
                        $Context.Token
                    }
                    return
                } else {
                    if (-not $Silent) {
                        Write-Host '⚠ ' -ForegroundColor Yellow -NoNewline
                        Write-Host "Access token remaining validity $accessTokenValidityText. Refreshing access token..."
                    }
                    $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $authClientID -RefreshToken ($Context.RefreshToken) -HostName $Context.HostName
                }
            } else {
                $refreshTokenValidity = [datetime]($Context.RefreshTokenExpirationDate) - (Get-Date)
                $refreshTokenIsValid = $refreshTokenValidity.Seconds -gt 0
                if ($refreshTokenIsValid) {
                    if (-not $Silent) {
                        Write-Host '⚠ ' -ForegroundColor Yellow -NoNewline
                        Write-Host 'Access token expired. Refreshing access token...'
                    }
                    $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $authClientID -RefreshToken ($Context.RefreshToken) -HostName $Context.HostName
                } else {
                    Write-Verbose "Using $Mode authentication..."
                    $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $authClientID -Scope $Scope -HostName $Context.HostName
                }
            }
            $Context.Token = ConvertTo-SecureString -AsPlainText $tokenResponse.access_token
            $Context.TokenExpirationDate = (Get-Date).AddSeconds($tokenResponse.expires_in)
            $Context.TokenType = $tokenResponse.access_token -replace $script:GitHub.TokenPrefixPattern
            $Context.RefreshToken = ConvertTo-SecureString -AsPlainText $tokenResponse.refresh_token
            $Context.RefreshTokenExpirationDate = (Get-Date).AddSeconds($tokenResponse.refresh_token_expires_in)

            if ($PSCmdlet.ShouldProcess('Access token', 'Update/refresh')) {
                Set-Context -Context $Context -Vault $script:GitHub.ContextVault
            }

            if ($PassThru) {
                $Context.Token
            }
        } finally {
            # Always release the mutex if we own it
            if ($mutexOwned -and $mutex) {
                try {
                    $mutex.ReleaseMutex()
                    Write-Verbose "Mutex released for context [$mutexName]"
                } catch {
                    Write-Warning "Failed to release mutex: $($_.Exception.Message)"
                }
            }

            # Dispose of the mutex object
            if ($mutex) {
                $mutex.Dispose()
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '8.1.0' }
