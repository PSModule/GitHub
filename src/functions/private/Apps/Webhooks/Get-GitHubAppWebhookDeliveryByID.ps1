function Get-GitHubAppWebhookDeliveryByID {
    <#
        .SYNOPSIS
        Get a delivery for an app webhook

        .DESCRIPTION
        Returns a delivery for the webhook configured for a GitHub App.

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.


        .EXAMPLE
        Get-GitHubAppWebhookDeliveryByID -ID 123456

        Returns the webhook configuration for the authenticated app.

        .NOTES
        [Get a delivery for an app webhook](https://docs.github.com/rest/apps/webhooks#get-a-delivery-for-an-app-webhook)
    #>
    [OutputType([GitHubWebhook])]
    [CmdletBinding()]
    param(
        # The ID of the delivery.
        [Parameter(Mandatory)]
        [Alias('DeliveryID', 'delivery_id')]
        [string] $ID,

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
            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/app/hook/deliveries/$ID"
                Method      = 'GET'
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                [GitHubWebhook](
                    @{
                        ID             = $_.id
                        GUID           = $_.guid
                        DeliveredAt    = $null -eq $_.delivered_at ? [datetime]::MinValue : [DateTime]::Parse($_.delivered_at)
                        Redelivery     = $_.redelivery
                        Duration       = $_.duration
                        Status         = $_.status
                        StatusCode     = $_.status_code
                        Event          = $_.event
                        Action         = $_.action
                        InstallationID = $_.installation.id
                        RepositoryID   = $_.repository.id
                        ThrottledAt    = $null -eq $_.throttled_at ? [datetime]::MinValue : [DateTime]::Parse($_.throttled_at)
                        URL            = $_.url
                        Request        = $_.request
                        Response       = $_.response
                    }
                )
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
