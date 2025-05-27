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

        .OUTPUTS
        GitHubWebhookDelivery        .LINK
        https://psmodule.io/GitHub/Functions/Webhooks/Get-GitHubAppWebhookDelivery/

        .NOTES
        [Get a delivery for an app webhook](https://docs.github.com/rest/apps/webhooks#get-a-delivery-for-an-app-webhook)

        .NOTES
        [Get a webhook configuration for an app](https://docs.github.com/rest/apps/webhooks#get-a-webhook-configuration-for-an-app)
    #>
    [OutputType([GitHubWebhookDelivery[]])]
    [CmdletBinding(DefaultParameterSetName = 'ByList')]
    param(
        # The ID of the delivery.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ByID'
        )]
        [string] $ID,

        # Only the ones to redeliver.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Redelivery')]
        [switch] $NeedingRedelivery,

        # The timespan to check for redeliveries in hours.
        [Parameter(ParameterSetName = 'Redelivery')]
        [int] $TimeSpan = -2,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'ByList')]
        [Parameter(ParameterSetName = 'Redelivery')]
        [System.Nullable[int]] $PerPage,

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
        Write-Debug "ParameterSetName: [$($PSCmdlet.ParameterSetName)]"
        switch ($PSCmdlet.ParameterSetName) {
            'ByID' {
                Write-Debug "ByID: [$ID]"
                Get-GitHubAppWebhookDeliveryByID -ID $ID -Context $Context
            }
            'Redelivery' {
                Write-Debug "Redelivery: [$NeedingRedelivery]"
                Get-GitHubAppWebhookDeliveryToRedeliver -Context $Context -PerPage $PerPage -TimeSpan $TimeSpan
            }
            default {
                Write-Debug 'ByList'
                Get-GitHubAppWebhookDeliveryByList -Context $Context -PerPage $PerPage
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
