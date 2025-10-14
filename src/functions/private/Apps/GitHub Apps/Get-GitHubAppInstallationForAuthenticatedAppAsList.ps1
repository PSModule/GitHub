function Get-GitHubAppInstallationForAuthenticatedAppAsList {
    <#
        .SYNOPSIS
        List installations for the authenticated app.

        .DESCRIPTION
        The permissions the installation has are included under the `permissions` key.

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.

        .EXAMPLE
        ```powershell
        Get-GitHubAppInstallationForAuthenticatedAppAsList
        ```

        List installations for the authenticated app.

        .OUTPUTS
        GitHubAppInstallation[]

        .NOTES
        [List installations for the authenticated app](https://docs.github.com/rest/apps/apps#list-installations-for-the-authenticated-app)
    #>
    [OutputType([GitHubAppInstallation])]
    [CmdletBinding()]
    param(
        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

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
            APIEndpoint = '/app/installations'
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            foreach ($installation in $_.Response) {
                [GitHubAppInstallation]::new($installation, $Context.App)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
