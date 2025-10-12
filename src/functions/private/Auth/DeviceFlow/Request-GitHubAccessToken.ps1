function Request-GitHubAccessToken {
    <#
        .SYNOPSIS
        Request a GitHub token using the Device Flow.

        .DESCRIPTION
        Request a GitHub token using the Device Flow.
        This will poll the GitHub API until the user has entered the code.

        .EXAMPLE
        ```powershell
        Request-GitHubAccessToken -DeviceCode $deviceCode -ClientID $ClientID -HostName 'github.com'
        ```

        This will poll the GitHub API until the user has entered the code.

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
        [securestring] $RefreshToken,

        # The host to connect to.
        [Parameter(Mandatory)]
        [string] $HostName
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $body = @{
            'client_id' = $ClientID
        }

        if ($PSBoundParameters.ContainsKey('RefreshToken')) {
            $body += @{
                'refresh_token' = (ConvertFrom-SecureString $RefreshToken -AsPlainText)
                'grant_type'    = 'refresh_token'
            }
        }

        if ($PSBoundParameters.ContainsKey('DeviceCode')) {
            $body += @{
                'device_code' = $DeviceCode
                'grant_type'  = 'urn:ietf:params:oauth:grant-type:device_code'
            }
        }

        $headers = @{
            'Accept' = 'application/json'
        }

        $RESTParams = @{
            Method  = 'POST'
            Uri     = "https://$HostName/login/oauth/access_token"
            Headers = $headers
            Body    = $body
        }

        Write-Debug ($RESTParams.GetEnumerator() | Out-String)
        $tokenResponse = Invoke-RestMethod @RESTParams -Verbose:$false
        Write-Debug ($tokenResponse | ConvertTo-Json | Out-String)
        return $tokenResponse

    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
