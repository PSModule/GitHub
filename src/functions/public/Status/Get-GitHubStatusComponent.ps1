function Get-GitHubStatusComponent {
    <#
        .SYNOPSIS
        Gets the status of GitHub components

        .DESCRIPTION
        Get the components for the page. Each component is listed along with its status - one of operational,
        degraded_performance, partial_outage, or major_outage.

        .EXAMPLE
        ```powershell
        Get-GitHubStatusComponent
        ```

        Gets the status of GitHub components

        .NOTES
        [Components](https://www.githubstatus.com/api#components)

        .LINK
        https://psmodule.io/GitHub/Functions/Status/Get-GitHubStatusComponent
    #>
    [OutputType([pscustomobject[]])]
    [Alias('Get-GitHubStatusComponents')]
    [CmdletBinding()]
    param(
        # The stamp to check status for.
        [Parameter()]
        [ValidateSet('Public', 'Europe', 'Australia', 'US')]
        [string] $Stamp = 'Public'
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $baseURL = $script:StatusBaseURL[$Stamp]

        $APIURI = "$baseURL/api/v2/components.json"
        $response = Invoke-RestMethod -Uri $APIURI -Method Get
        $response.components
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
