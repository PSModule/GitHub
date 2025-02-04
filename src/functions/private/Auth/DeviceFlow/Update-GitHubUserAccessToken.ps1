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
        [Refreshing user access tokens](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/refreshing-user-access-tokens)
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
        try {
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
                Set-Context -Context $Context -ID $Context.ID
            }

            if ($PassThru) {
                $Context.Token
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
