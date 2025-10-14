function Wait-GitHubAccessToken {
    <#
        .SYNOPSIS
        Waits for the GitHub Device Flow to complete.

        .DESCRIPTION
        Waits for the GitHub Device Flow to complete.
        This will poll the GitHub API until the user has entered the code.

        .EXAMPLE
        ```powershell
        Wait-GitHubAccessToken -DeviceCode $deviceCode -ClientID $ClientID -Interval $interval
        ```

        This will poll the GitHub API until the user has entered the code.

        .EXAMPLE
        ```powershell
        Wait-GitHubAccessToken -Refresh -ClientID $ClientID
        ```

        .NOTES
        For more info about the Device Flow visit:
        https://docs.github.com/apps/creating-github-apps/writing-code-for-a-github-app/building-a-cli-with-a-github-app
    #>
    [OutputType([PSCustomObject])]
    [CmdletBinding(DefaultParameterSetName = 'DeviceFlow')]
    param(
        # The Client ID of the GitHub App.
        [Parameter(Mandatory)]
        [string] $ClientID,

        # The device code used to request the access token.
        [Parameter(
            Mandatory,
            ParameterSetName = 'DeviceFlow'
        )]
        [string] $DeviceCode,

        # The refresh token used to request a new access token.
        [Parameter(
            Mandatory,
            ParameterSetName = 'RefreshToken'
        )]
        [securestring] $RefreshToken,

        # The host to connect to.
        [Parameter(Mandatory)]
        [string] $HostName,

        # The interval to wait between polling for the token.
        [Parameter()]
        [int] $Interval = 5
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        do {
            if ($RefreshToken) {
                $response = Request-GitHubAccessToken -ClientID $ClientID -RefreshToken $RefreshToken -HostName $HostName
            } else {
                $response = Request-GitHubAccessToken -ClientID $ClientID -DeviceCode $DeviceCode -HostName $HostName
            }
            if ($response.error) {
                switch ($response.error) {
                    'authorization_pending' {
                        # The user has not yet entered the code.
                        # Wait, then poll again.
                        Write-Debug $response.error_description
                        Start-Sleep -Seconds $interval
                        continue
                    }
                    'slow_down' {
                        # The app polled too fast.
                        # Wait for the interval plus 5 seconds, then poll again.
                        Write-Debug $response.error_description
                        Start-Sleep -Seconds ($interval + 5)
                        continue
                    }
                    'expired_token' {
                        # The 'device_code' expired, and the process needs to restart.
                        Write-Error $response.error_description
                        exit 1
                    }
                    'unsupported_grant_type' {
                        # The 'grant_type' is not supported.
                        Write-Error $response.error_description
                        exit 1
                    }
                    'incorrect_client_credentials' {
                        # The 'client_id' is not valid.
                        Write-Error $response.error_description
                        exit 1
                    }
                    'incorrect_device_code' {
                        # The 'device_code' is not valid.
                        Write-Error $response.error_description
                        exit 2
                    }
                    'access_denied' {
                        # The user cancelled the process. Stop polling.
                        Write-Error $response.error_description
                        exit 1
                    }
                    'device_flow_disabled' {
                        # The GitHub App does not support the Device Flow.
                        Write-Error $response.error_description
                        exit 1
                    }
                    default {
                        # The response contains an access token. Stop polling.
                        Write-Error 'Unknown error:'
                        Write-Error $response.error
                        Write-Error $response.error_description
                        Write-Error $response.error_uri
                        break
                    }
                }
            }
        } until ($response.access_token)
        $response
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
