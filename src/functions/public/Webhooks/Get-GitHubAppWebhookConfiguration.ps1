function Get-GitHubAppWebhookConfiguration {
    <#
        .SYNOPSIS
        Get a webhook configuration for an app

        .DESCRIPTION
        Returns the webhook configuration for a GitHub App. For more information about configuring a webhook for your app, see
        "[Creating a GitHubApp](/developers/apps/creating-a-github-app)."

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.

        .EXAMPLE
        ```powershell
        Get-GitHubAppWebhookConfiguration
        ```

        Returns the webhook configuration for the authenticated app.

        .LINK
        https://psmodule.io/GitHub/Functions/Webhooks/Get-GitHubAppWebhookConfiguration/

        .NOTES
        [Get a webhook configuration for an app](https://docs.github.com/rest/apps/webhooks#get-a-webhook-configuration-for-an-app)
    #>
    [CmdletBinding()]
    param(
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
            Method      = 'GET'
            APIEndpoint = '/app/hook/config'
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            [GitHubWebhookConfiguration]::new($_.Response)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
