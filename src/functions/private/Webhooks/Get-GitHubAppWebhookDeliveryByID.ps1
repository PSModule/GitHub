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

        .OUTPUTS
        GitHubWebhookDelivery

        .NOTES
        [Get a delivery for an app webhook](https://docs.github.com/rest/apps/webhooks#get-a-delivery-for-an-app-webhook)
    #>
    [OutputType([GitHubWebhookDelivery])]
    [CmdletBinding()]
    param(
        # The ID of the delivery.
        [Parameter(Mandatory)]
        [string] $ID,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType APP
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/app/hook/deliveries/$ID"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            [GitHubWebhookDelivery]::new($_.Response)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
