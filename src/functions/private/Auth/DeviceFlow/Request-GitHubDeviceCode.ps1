﻿function Request-GitHubDeviceCode {
    <#
        .SYNOPSIS
        Request a GitHub Device Code.

        .DESCRIPTION
        Request a GitHub Device Code.

        .EXAMPLE
        Request-GitHubDeviceCode -ClientID $ClientID -Mode $Mode -HostName 'github.com'

        This will request a GitHub Device Code.

        .NOTES
        For more info about the Device Flow visit:
        https://docs.github.com/apps/creating-github-apps/writing-code-for-a-github-app/building-a-cli-with-a-github-app
    #>
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param(
        # The Client ID of the GitHub App.
        [Parameter(Mandatory)]
        [string] $ClientID,

        # The scope of the access token, when using OAuth authentication.
        # Provide the list of scopes as space-separated values.
        # For more information on scopes visit:
        # https://docs.github.com/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps
        [Parameter()]
        [string] $Scope = 'gist, read:org, repo, workflow',

        # The host to connect to.
        [Parameter(Mandatory)]
        [string] $HostName
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $headers = @{
            Accept = 'application/json'
        }

        $body = @{
            client_id = $ClientID
            scope     = $Scope
        }

        $RESTParams = @{
            Method  = 'POST'
            Uri     = "https://$HostName/login/device/code"
            Headers = $headers
            Body    = $body
        }

        Write-Debug ($RESTParams.GetEnumerator() | Out-String)
        $deviceCodeResponse = Invoke-RestMethod @RESTParams -Verbose:$false
        return $deviceCodeResponse
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
