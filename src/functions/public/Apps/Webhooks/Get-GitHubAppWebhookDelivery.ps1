function Get-GitHubAppWebhookDelivery {
    <#
        .SYNOPSIS
        List deliveries for an app webhook or get a delivery for an app webhook by ID.

        .DESCRIPTION
        Returns a list of webhook deliveries or a specific delivery for the webhook configured for a GitHub App.

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.

        .EXAMPLE
        Get-GitHubAppWebhookDelivery

        Returns a list of webhook deliveries for the webhook for the authenticated app.

        .EXAMPLE
        Get-GitHubAppWebhookDelivery -ID 123456

        Returns the webhook delivery with the ID `123456` for the authenticated app.

        .NOTES
        [Get a delivery for an app webhook](https://docs.github.com/rest/apps/webhooks#get-a-delivery-for-an-app-webhook)
        [Get a webhook configuration for an app](https://docs.github.com/rest/apps/webhooks#get-a-webhook-configuration-for-an-app)
    #>
    [OutputType([GitHubWebhook[]])]
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        # The ID of the delivery.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ByID',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('DeliveryID', 'delivery_id')]
        [string] $ID,

        # Only the ones to redeliver.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ToRedeliver')]
        [switch] $ToRedeliver,

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
            switch ($PSCmdlet.ParameterSetName) {
                'ByID' {
                    Get-GitHubAppWebhookDeliveryByID -ID $ID -Context $Context
                }
                'ToRedeliver' {
                    Get-GitHubAppWebhookDeliveryToRedeliver -Context $Context
                }
                '__AllParameterSets' {
                    Get-GitHubAppWebhookDeliveryByList -Context $Context
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
