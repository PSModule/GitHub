function Update-GitHubAppWebhookConfiguration {
    <#
        .SYNOPSIS
        Update a webhook configuration for an app

        .DESCRIPTION
        Updates the webhook configuration for a GitHub App. For more information about configuring a webhook for your app, see
        "[Creating a GitHub App](/developers/apps/creating-a-github-app)."

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.

        .EXAMPLE
        Update-GitHubAppWebhookConfiguration -URL 'https://example.com' -ContentType 'json' -Secret 'mysecret' -EnableSsl

        Output:
        ```powershell
        ContentType: json
        UseSsl:      True
        Secret:      mysecret
        Url:         https://example.com
        ```

        Updates the webhook configuration for the authenticated app to deliver payloads to `https://example.com` with a `json` content type
        and a secret of `mysecret` enabling SSL verification when delivering payloads.

        .OUTPUTS
        GitHubWebhookConfiguration

        .LINK
        https://psmodule.io/GitHub/Functions/Webhooks/Update-GitHubAppWebhookConfiguration

        .NOTES
        [Update a webhook configuration for an app](https://docs.github.com/rest/apps/webhooks#update-a-webhook-configuration-for-an-app)
    #>
    [OutputType([GitHubWebhookConfiguration])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The URL to which the payloads will be delivered.
        [Parameter()]
        [string] $Url,

        # The media type used to serialize the payloads.
        [Parameter()]
        [ValidateSet('json', 'form')]
        [string] $ContentType,

        # If provided, the `secret` will be used as the `key` to generate the HMAC hex digest value for delivery signature headers.
        [Parameter()]
        [string] $Secret,

        # Disable SSL verification when delivering payloads.
        [Parameter()]
        [switch] $DisableSsl,

        # Enables SSL verification when delivering payloads.
        [Parameter()]
        [switch] $EnableSsl,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context -Anonymous $Anonymous
        Assert-GitHubContext -Context $Context -AuthType APP
    }

    process {
        $body = @{
            url          = $Url
            content_type = $ContentType
            secret       = $Secret
            insecure_ssl = $PSBoundParameters.ContainsKey($InsecureSSL) ? ($InsecureSSL ? 1 : 0) : $null
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'PATCH'
            APIEndpoint = '/app/hook/config'
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess('webhook configuration', 'Update')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
