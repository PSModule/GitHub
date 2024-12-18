﻿function Get-GitHubAppWebhookDeliveryByID {
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
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}