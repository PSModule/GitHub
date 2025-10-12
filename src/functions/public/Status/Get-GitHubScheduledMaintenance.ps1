function Get-GitHubScheduledMaintenance {
    <#
        .SYNOPSIS
        Gets the status of GitHub scheduled maintenance

        .DESCRIPTION
        Scheduled maintenances are planned outages, upgrades, or general notices that you're working
        on infrastructure and disruptions may occurr. A close sibling of Incidents, each usually goes
        through a progression of statuses listed below, with an impact calculated from a blend of
        component statuses (or an optional override).

        Status: Scheduled, In Progress, Verifying, or Completed
        Impact: None (black), Minor (yellow), Major (orange), or Critical (red)

        .EXAMPLE
        ```pwsh
        Get-GitHubScheduledMaintenance
        ```

        Get a list of the 50 most recent scheduled maintenances.
        This includes scheduled maintenances as described in the above two endpoints, as well as those in the Completed state.

        .EXAMPLE
        ```pwsh
        Get-GitHubScheduledMaintenance -Active
        ```

        Get a list of any active maintenances.

        .EXAMPLE
        ```pwsh
        Get-GitHubScheduledMaintenance -Upcoming
        ```

        Get a list of any upcoming maintenances.

        .NOTES
        [Scheduled maintenances](https://www.githubstatus.com/api#scheduled-maintenances)

        .LINK
        https://psmodule.io/GitHub/Functions/Status/Get-GitHubScheduledMaintenance
    #>
    [CmdletBinding()]
    param(
        # Get a list of any active maintenances.
        # This endpoint will only return scheduled maintenances in the In Progress or Verifying state.
        [Parameter()]
        [switch] $Active,

        # Get a list of any upcoming maintenances.
        # This endpoint will only return scheduled maintenances still in the Scheduled state.
        [Parameter()]
        [switch] $Upcoming,

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

        if ($Active) {
            $APIURI = "$baseURL/api/v2/scheduled-maintenances/active.json"
            $response = Invoke-RestMethod -Uri $APIURI -Method Get
            $response.scheduled_maintenances
            return
        }

        if ($Upcoming) {
            $APIURI = "$baseURL/api/v2/scheduled-maintenances/upcoming.json"
            $response = Invoke-RestMethod -Uri $APIURI -Method Get
            $response.scheduled_maintenances
            return
        }

        $APIURI = "$baseURL/api/v2/scheduled-maintenances.json"
        $response = Invoke-RestMethod -Uri $APIURI -Method Get
        $response.scheduled_maintenances

    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
