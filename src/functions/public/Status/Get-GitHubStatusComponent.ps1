function Get-GitHubStatusComponent {
    <#
        .SYNOPSIS
        Gets the status of GitHub components

        .DESCRIPTION
        Get the components for the page. Each component is listed along with its status - one of operational,
        degraded_performance, partial_outage, or major_outage.

        .EXAMPLE
        Get-GitHubStatusComponent

        Gets the status of GitHub components

        .NOTES
        [Components](https://www.githubstatus.com/api#components)
    #>
    [OutputType([pscustomobject[]])]
    [Alias('Get-GitHubStatusComponents')]
    [CmdletBinding()]
    param(
        # The stanmp to use for the API call.
        [Parameter()]
        [ValidateSet('public', 'eu')]
        [string] $Stamp = 'public'
    )

    $baseURL = $script:StatusBaseURL[$Stamp]

    $APIURI = "$baseURL/api/v2/components.json"
    $response = Invoke-RestMethod -Uri $APIURI -Method Get
    $response.components
}
