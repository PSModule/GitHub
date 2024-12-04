﻿function Get-GitHubAppWebhookConfiguration {
    <#
        .SYNOPSIS
        Get a webhook configuration for an app

        .DESCRIPTION
        Returns the webhook configuration for a GitHub App. For more information about configuring a webhook for your app, see
        "[Creating a GitHubApp](/developers/apps/creating-a-github-app)."

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.

        .EXAMPLE
        Get-GitHubAppWebhookConfiguration

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
        APIEndpoint = '/app/hook/config'
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}