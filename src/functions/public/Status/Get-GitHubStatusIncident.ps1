function Get-GitHubStatusIncident {
    <#
        .SYNOPSIS
        Gets the status of GitHub incidents

        .DESCRIPTION
        Incidents are the cornerstone of any status page, being composed of many incident updates.
        Each incident usually goes through a progression of statuses listed below, with an impact
        calculated from a blend of component statuses (or an optional override).

        Status: Investigating, Identified, Monitoring, Resolved, or Postmortem
        Impact: None (black), Minor (yellow), Major (orange), or Critical (red)

        .EXAMPLE
        Get-GitHubStatusIncident

        Gets the status of GitHub incidents

        .EXAMPLE
        Get-GitHubStatusIncident -Unresolved

        Gets the status of GitHub incidents that are unresolved

        .NOTES
        [Incidents](https://www.githubstatus.com/api#incidents)
    #>
    [OutputType([pscustomobject[]])]
    [Alias('Get-GitHubStatusIncidents')]
    [CmdletBinding()]
    param(
        # Gets the status of GitHub incidents that are unresolved
        [Parameter()]
        [switch] $Unresolved,

        # The stanmp to use for the API call.
        [Parameter()]
        [ValidateSet('public', 'eu')]
        [string] $Stamp = 'public'
    )

    $baseURL = $script:StatusBaseURL[$Stamp]

    if ($Unresolved) {
        $APIURI = "$baseURL/api/v2/incidents/unresolved.json"
        $response = Invoke-RestMethod -Uri $APIURI -Method Get
        $response.incidents
        return
    }

    $APIURI = "$baseURL/api/v2/incidents.json"
    $response = Invoke-RestMethod -Uri $APIURI -Method Get
    $response.incidents
}
