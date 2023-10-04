function Get-GitHubStatusComponents {
    <#
        .SYNOPSIS
        Gets the status of GitHub components

        .DESCRIPTION
        Get the components for the page. Each component is listed along with its status - one of operational, degraded_performance, partial_outage, or major_outage.

        .EXAMPLE
        Get-GitHubStatusComponents

        Gets the status of GitHub components

        .NOTES
        https://www.githubstatus.com/api#components
    #>
    [OutputType([pscustomobject[]])]
    [CmdletBinding()]
    param()

    $APIURI = 'https://www.githubstatus.com/api/v2/components.json'
    $response = Invoke-RestMethod -Uri $APIURI -Method Get
    $response.components
}
