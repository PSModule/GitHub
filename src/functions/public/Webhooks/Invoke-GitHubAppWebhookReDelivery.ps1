function Invoke-GitHubAppWebhookReDelivery {
    <#
        .SYNOPSIS
        Redeliver a delivery for an app webhook

        .DESCRIPTION
        Redeliver a delivery for the webhook configured for a GitHub App.

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.

        .EXAMPLE
        ```powershell
        Invoke-GitHubAppWebhookReDelivery -ID 12345
        ```

        Redelivers the delivery with the ID `12345`.

        .LINK
        https://psmodule.io/GitHub/Functions/Webhooks/Invoke-GitHubAppWebhookReDelivery

        .NOTES
        [Redeliver a delivery for an app webhook](https://docs.github.com/rest/apps/webhooks#redeliver-a-delivery-for-an-app-webhook)
    #>
    [OutputType([void])]
    [Alias('Redeliver-GitHubAppWebhookDelivery')]
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseApprovedVerbs', '', Scope = 'Function',
        Justification = 'Redeliver is the only thing that makes sense when triggering a webhook delivery again.'
    )]
    param(
        # The ID of the delivery.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $ID,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType APP
    }

    process {
        $apiParams = @{
            Method      = 'POST'
            APIEndpoint = "/app/hook/deliveries/$ID/attempts"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("[$ID]", 'Redeliver event')) {
            Invoke-GitHubAPI @apiParams | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
