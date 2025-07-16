function Update-GitHubUserAccessToken {
    <#
        .SYNOPSIS
        Updates the GitHub access token.

        .DESCRIPTION
        Updates the GitHub access token. If the access token is still valid, it will not be refreshed.

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
    [OutputType([GitHubContext])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '',
        Justification = 'Is the CLI part of the module.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'The tokens are recieved as clear text. Mitigating exposure by removing variables and performing garbage collection.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'Reason for suppressing'
    )]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context,

        # Return the updated context.
        [Parameter()]
        [switch] $PassThru,

        # Suppress output messages.
        [Parameter()]
        [switch] $Silent,

        # Timeout in milliseconds for waiting on mutex. Default is 30 seconds.
        [Parameter()]
        [int] $TimeoutMs = 30000
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType UAT
    }

    process {
        if (Test-GitHubAccessTokenRefreshRequired -Context $Context) {
            $lockName = "PSModule.GitHub/$($Context.ID)"
            $lock = $null
            try {
                $lock = [System.Threading.Mutex]::new($false, $lockName)
                $updateToken = $lock.WaitOne(0)

                if ($updateToken) {
                    try {
                        $refreshTokenValidity = [datetime]($Context.RefreshTokenExpiresAt) - [datetime]::Now
                        $refreshTokenIsValid = $refreshTokenValidity.TotalSeconds -gt 0
                        if ($refreshTokenIsValid) {
                            if (-not $Silent) {
                                Write-Host '⚠ ' -ForegroundColor Yellow -NoNewline
                                Write-Host 'Access token expired. Refreshing access token...'
                            }
                            $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $Context.AuthClientID -RefreshToken $Context.RefreshToken -HostName $Context.HostName
                        } else {
                            Write-Verbose "Using $($Context.DeviceFlowType) authentication..."
                            $tokenResponse = Invoke-GitHubDeviceFlowLogin -ClientID $Context.AuthClientID -HostName $Context.HostName
                        }
                        $Context.Token = ConvertTo-SecureString -AsPlainText $tokenResponse.access_token
                        $Context.TokenExpiresAt = ([DateTime]::Now).AddSeconds($tokenResponse.expires_in)
                        $Context.TokenType = $tokenResponse.access_token -replace $script:GitHub.TokenPrefixPattern
                        $Context.RefreshToken = ConvertTo-SecureString -AsPlainText $tokenResponse.refresh_token
                        $Context.RefreshTokenExpiresAt = ([DateTime]::Now).AddSeconds($tokenResponse.refresh_token_expires_in)

                        if ($PSCmdlet.ShouldProcess('Access token', 'Update/refresh')) {
                            Set-Context -Context $Context -Vault $script:GitHub.ContextVault
                        }
                    } finally {
                        $lock.ReleaseMutex()
                    }
                } else {
                    Write-Verbose "Access token is not valid. Waiting for mutex to be released (timeout: $($TimeoutMs)ms)..."
                    try {
                        if ($lock.WaitOne($TimeoutMs)) {
                            $Context = Resolve-GitHubContext -Context $Context.ID
                            $lock.ReleaseMutex()
                        } else {
                            Write-Warning 'Timeout waiting for token update. Proceeding with current token state.'
                        }
                    } catch [System.Threading.AbandonedMutexException] {
                        Write-Debug 'Mutex was abandoned by another process. Re-checking token state...'
                        $Context = Resolve-GitHubContext -Context $Context.ID
                    }
                }
            } finally {
                if ($lock) {
                    $lock.Dispose()
                }
            }
        }
        if ($PassThru) {
            return $Context
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
