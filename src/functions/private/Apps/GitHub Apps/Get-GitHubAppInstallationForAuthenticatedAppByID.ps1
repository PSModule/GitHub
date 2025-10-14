function Get-GitHubAppInstallationForAuthenticatedAppByID {
    <#
        .SYNOPSIS
        Get an installation for the authenticated app.

        .DESCRIPTION
        Enables an authenticated GitHub App to find an installation's information using the installation id..

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.

        .EXAMPLE
        ```powershell
        Get-GitHubAppInstallationForAuthenticatedAppByID -ID 123456
        ```

        Get an installation for the authenticated app with the specified ID.

        .OUTPUTS
        GitHubAppInstallation

        .NOTES
        [Get an installation for the authenticated app](https://docs.github.com/rest/apps/apps#get-an-installation-for-the-authenticated-app)
    #>
    [OutputType([GitHubAppInstallation])]
    [CmdletBinding()]
    param(
        # The unique identifier of the installation.
        [Parameter(Mandatory)]
        [int] $ID,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType APP
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/app/installations/$ID"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            [GitHubAppInstallation]::new($_.Response, $Context.App)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
