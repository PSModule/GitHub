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
        [Parameter(Mandatory)]
        [GitHubContext] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType APP
    }

    process {
        $checkPoint = (Get-Date).AddHours($TimeSpan)
        Get-GitHubAppWebhookDeliveryByList -Context $Context -PerPage $PerPage | Where-Object { $_.DeliveredAt -gt $checkPoint } |
            Group-Object -Property GUID | Where-Object { $_.Group.Status -notcontains 'OK' } | ForEach-Object {
                $refObject = $_.Group | Sort-Object -Property DeliveredAt
                [GitHubWebhookRedelivery]@{
                    Attempts       = $_.Count
                    GUID           = $_.Name
                    Status         = $refObject.Status
                    StatusCode     = $refObject.StatusCode
                    Event          = $refObject.Event
                    Action         = $refObject.Action
                    Duration       = $_.Group.Duration | Measure-Object -Average | Select-Object -ExpandProperty Average
                    ID             = $refObject.ID
                    DeliveredAt    = $refObject.DeliveredAt
                    Redelivery     = $refObject.Redelivery
                    InstallationID = $refObject.InstallationID
                    RepositoryID   = $refObject.RepositoryID
                    ThrottledAt    = $refObject.ThrottledAt
                    URL            = $refObject.URL
                    Request        = $refObject.Request
                    Response       = $refObject.Response
                }
            }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
