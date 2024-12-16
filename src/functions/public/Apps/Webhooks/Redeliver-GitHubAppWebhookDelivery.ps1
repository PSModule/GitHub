function Redeliver-GitHubAppWebhookDelivery {
    <#
        .SYNOPSIS
        Redeliver a delivery for an app webhook

        .DESCRIPTION
        Redeliver a delivery for the webhook configured for a GitHub App.

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.

        .EXAMPLE
        Redeliver-GitHubAppWebhookDelivery -ID 12345

        Redelivers the delivery with the ID `12345`.

        .NOTES
        [Redeliver a delivery for an app webhook](https://docs.github.com/rest/apps/webhooks#redeliver-a-delivery-for-an-app-webhook)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseApprovedVerbs', '', Scope = 'Function',
        Justification = 'Redeliver is the only thing that makes sense when triggering a webhook delivery again.'
    )]
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
                APIEndpoint = "/app/hook/deliveries/$ID/attempts"
                Method      = 'post'
            }

            if ($PSCmdlet.ShouldProcess('webhook delivery', 'Redeliver')) {
                Invoke-GitHubAPI @inputObject | ForEach-Object {
                    Write-Output $_.Response
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
