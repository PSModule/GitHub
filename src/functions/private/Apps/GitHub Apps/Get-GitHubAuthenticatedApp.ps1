filter Get-GitHubAuthenticatedApp {
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
        Get-GitHubAuthenticatedApp

        Get the authenticated app.

        .NOTES
        [Get the authenticated app](https://docs.github.com/rest/apps/apps#get-an-app)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType App
    }

    process {
        try {
            $Context = Resolve-GitHubContext -Context $Context

            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/app'
                Method      = 'GET'
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }
    end {
        Write-Debug "[$stackPath] - End"
    }
}
