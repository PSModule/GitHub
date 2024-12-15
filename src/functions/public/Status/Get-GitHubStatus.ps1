function Get-GitHubStatus {
    <#
        .SYNOPSIS
        Gets the status of GitHub services

        .DESCRIPTION
        Get a summary of the status page, including a status indicator, component statuses, unresolved incidents,
        and any upcoming or in-progress scheduled maintenances. Get the status rollup for the whole page. This endpoint
        includes an indicator - one of none, minor, major, or critical, as well as a human description of the blended
        component status. Examples of the blended status include "All Systems Operational", "Partial System Outage",
        and "Major Service Outage".

        .EXAMPLE
        Get-GitHubStatus

        Gets the status of GitHub services

        .EXAMPLE
        Get-GitHubStatus -Summary

        Gets a summary of the status page, including a status indicator, component statuses, unresolved incidents,
        and any upcoming or in-progress scheduled maintenances.

        .NOTES
        [Summary](https://www.githubstatus.com/api#summary)
        [Status](https://www.githubstatus.com/api#status)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # Gets a summary of the status page, including a status indicator, component statuses, unresolved incidents,
        # and any upcoming or in-progress scheduled maintenances.
        [Parameter()]
        [switch] $Summary,

        # The stanmp to use for the API call.
        [Parameter()]
        [ValidateSet('public', 'eu')]
        [string] $Stamp = 'public'
    )
    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        try {
            $baseURL = $script:StatusBaseURL[$Stamp]

            if ($Summary) {
                $APIURI = "$baseURL/api/v2/summary.json"
                $response = Invoke-RestMethod -Uri $APIURI -Method Get
                $response
                return
            }

            $APIURI = "$baseURL/api/v2/status.json"
            $response = Invoke-RestMethod -Uri $APIURI -Method Get
            $response.status
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
