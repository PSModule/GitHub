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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Long links for documentation.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Is the CLI part of the module.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'The tokens are recieved as clear text. Mitigating exposure by removing variables and performing garbage collection.')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context
    $gitHubConfig = Get-GitHubConfig

    Write-Verbose "Reusing previously stored ClientID: [$($Context.AuthClientID)]"
    $authClientID = $Context.AuthClientID
    $accessTokenValidity = [datetime]($Context.TokenExpirationDate) - (Get-Date)
    $accessTokenIsValid = $accessTokenValidity.Seconds -gt 0
    $hours = $accessTokenValidity.Hours.ToString().PadLeft(2, '0')
    $minutes = $accessTokenValidity.Minutes.ToString().PadLeft(2, '0')
    $seconds = $accessTokenValidity.Seconds.ToString().PadLeft(2, '0')
    $accessTokenValidityText = "$hours`:$minutes`:$seconds"
    if ($accessTokenIsValid) {
        if ($accessTokenValidity.TotalHours -gt $gitHubConfig.AccessTokenGracePeriodInHours) {
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
    $settings = @{
        Token                      = ConvertTo-SecureString -AsPlainText $tokenResponse.access_token
        TokenExpirationDate        = (Get-Date).AddSeconds($tokenResponse.expires_in)
        TokenType                  = $tokenResponse.access_token -replace $script:Auth.TokenPrefixPattern
        RefreshToken               = ConvertTo-SecureString -AsPlainText $tokenResponse.refresh_token
        RefreshTokenExpirationDate = (Get-Date).AddSeconds($tokenResponse.refresh_token_expires_in)
    }

    if ($PSCmdlet.ShouldProcess('Access token', 'Update/refresh')) {
        Set-GitHubContextSetting @settings -Context $Context
    }
}
