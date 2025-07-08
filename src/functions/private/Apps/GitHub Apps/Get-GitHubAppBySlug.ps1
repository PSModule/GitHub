function Get-GitHubAppBySlug {
    <#
        .SYNOPSIS
        Get an app

        .DESCRIPTION
        Gets a single GitHub App using the app's slug.

        .EXAMPLE
        Get-GitHubAppByName -AppSlug 'github-actions'

        Gets the GitHub App with the slug 'github-actions'.

        .NOTES
        [Get an app](https://docs.github.com/rest/apps/apps#get-an-app)
    #>
    [OutputType([GitHubApp])]
    [CmdletBinding()]
    param(
        # The AppSlug is just the URL-friendly name of a GitHub App.
        # You can find this on the settings page for your GitHub App (e.g., https://github.com/settings/apps/<app_slug>).
        # Example: 'github-actions'
        [Parameter(Mandatory)]
        [string] $Slug,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/apps/$Slug"
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
