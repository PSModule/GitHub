﻿function Get-GitHubAppWebhookDelivery {
    <#
        .SYNOPSIS
        List deliveries for an app webhook

        .DESCRIPTION
        Returns a list of webhook deliveries for the webhook configured for a GitHub App.

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.

        .EXAMPLE
        Get-GitHubAppWebhookDelivery

        Returns the webhook configuration for the authenticated app.

        .NOTES
        [Get a webhook configuration for an app](https://docs.github.com/rest/apps/webhooks#get-a-webhook-configuration-for-an-app)
    #>
    [CmdletBinding()]
    param(
        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $inputObject = @{
        Context     = $Context
        APIEndpoint = '/app/hook/deliveries'
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}