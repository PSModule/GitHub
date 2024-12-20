function Get-GitHubAppWebhookDeliveryToRedeliver {
    <#
        .SYNOPSIS
        Short description

        .DESCRIPTION
        Long description

        .EXAMPLE
        An example

        .NOTES
        [Ttle](link)
    #>
    [CmdletBinding()]
    param(
        # The timespan to check for redeliveries in hours.
        [Parameter()]
        [int] $TimeSpan = -2,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType APP
    }

    process {
        try {
            $allDeliveries = Get-GitHubAppWebhookDeliveryByList -Context $Context -PerPage $PerPage
            $checkPoint = (Get-Date).AddHours($TimeSpan)
            $allDeliveries | Where-Object { $_.DeliveredAt -gt $checkPoint } | Group-Object -Property guid |
                Where-Object { $_.Group.status -notcontains 'OK' } | ForEach-Object {
                    [pscustomobject]@{
                        guid      = $_.name
                        redeliver = $_.Group.status -notcontains 'OK'
                        id        = $_.Group[0].id
                    }
                } | Where-Object { $_.redeliver }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
