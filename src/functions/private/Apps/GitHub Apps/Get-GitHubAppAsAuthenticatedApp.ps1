filter Get-GitHubAppAsAuthenticatedApp {
    <#
        .SYNOPSIS
        Get the authenticated app

        .DESCRIPTION
        Returns the GitHub App associated with the authentication credentials used. To see how many app installations are associated with this
        GitHub App, see the `installations_count` in the response. For more details about your app's installations, see the
        "[List installations for the authenticated app](https://docs.github.com/rest/apps/apps#list-installations-for-the-authenticated-app)"
        endpoint.

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.

        .EXAMPLE
        Get-GitHubAppAsAuthenticatedApp

        Get the authenticated app.

        .NOTES
        [Get the authenticated app](https://docs.github.com/rest/apps/apps#get-an-app)
    #>
    [OutputType([GitHubApp])]
    [CmdletBinding()]
    param(
        # The context to run the command in. Used to get the details for the API call.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType App
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = '/app'
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            [GitHubApp]::new($_.Response)
        }
    }
    end {
        Write-Debug "[$stackPath] - End"
    }
}
