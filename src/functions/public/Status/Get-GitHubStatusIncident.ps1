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
        ```powershell
        Get-GitHubStatusIncident
        ```

        Gets the status of GitHub incidents

        .EXAMPLE
        ```powershell
        Get-GitHubStatusIncident -Unresolved
        ```

        Gets the status of GitHub incidents that are unresolved

        .NOTES
        [Incidents](https://www.githubstatus.com/api#incidents)

        .LINK
        https://psmodule.io/GitHub/Functions/Status/Get-GitHubStatusIncident
    #>
    [OutputType([pscustomobject[]])]
    [Alias('Get-GitHubStatusIncidents')]
    [CmdletBinding()]
    param(
        # Gets the status of GitHub incidents that are unresolved
        [Parameter()]
        [switch] $Unresolved,

        # The stamp to check status for.
        [Parameter()]
        [string] $Stamp = 'Public'
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $baseURL = $script:GitHub.Stamps[$Stamp]

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

    end {
        Write-Debug "[$stackPath] - End"
    }
}
