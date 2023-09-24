﻿function Request-GitHubAccessToken {
    <#
        .SYNOPSIS
        Request a GitHub token using the Device Flow.

        .DESCRIPTION
        Request a GitHub token using the Device Flow.
        This will poll the GitHub API until the user has entered the code.

        .EXAMPLE
        Request-GitHubAccessToken -DeviceCode $deviceCode -ClientID $ClientID

        This will poll the GitHub API until the user has entered the code.

        .NOTES
        For more info about the Device Flow visit:
        https://docs.github.com/en/apps/creating-github-apps/writing-code-for-a-github-app/building-a-cli-with-a-github-app
    #>
    [OutputType([PSCustomObject])]
    [CmdletBinding(DefaultParameterSetName = 'DeviceFlow')]
    param(
        # The Client ID of the GitHub App.
        [Parameter(Mandatory)]
        [string] $ClientID,

        # The 'device_code' used to request the access token.
        [Parameter(
            Mandatory,
            ParameterSetName = 'DeviceFlow'
        )]
        [string] $DeviceCode,

        # The refresh token used create a new access token.
        [Parameter(
            Mandatory,
            ParameterSetName = 'RefreshToken'
        )]
        [securestring] $RefreshToken
    )

    $body = @{
        'client_id' = $ClientID
    }

    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($RefreshToken)
    $RefreshTokenAsPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

    if ($PSBoundParameters.ContainsKey('RefreshToken')) {
        $body += @{
            'refresh_token' = $RefreshTokenAsPlainText
            'grant_type'    = 'refresh_token'
        }
    }

    if ($PSBoundParameters.ContainsKey('DeviceCode')) {
        $body += @{
            'device_code' = $DeviceCode
            'grant_type'  = 'urn:ietf:params:oauth:grant-type:device_code'
        }
    }

    $RESTParams = @{
        Uri     = 'https://github.com/login/oauth/access_token'
        Method  = 'POST'
        Body    = $body
        Headers = @{ 'Accept' = 'application/json' }
    }

    try {
        Write-Verbose ($RESTParams.GetEnumerator() | Out-String)

        $tokenResponse = Invoke-RestMethod @RESTParams -Verbose:$false
        return $tokenResponse
    } catch {
        Write-Error $_
        throw $_
    }
}
