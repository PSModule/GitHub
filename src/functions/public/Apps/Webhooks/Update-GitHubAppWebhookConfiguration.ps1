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
        Update-GitHubAppWebhookConfiguration -URL 'https://example.com' -ContentType 'json' -Secret 'mysecret' -InsecureSSL

        Updates the webhook configuration for the authenticated app to deliver payloads to `https://example.com` with a `json` content type
        and a secret of `mysecret` disabling SSL verification when delivering payloads.

        .NOTES
        [Update a webhook configuration for an app](https://docs.github.com/rest/apps/webhooks#update-a-webhook-configuration-for-an-app)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The URL to which the payloads will be delivered.
        [Parameter()]
        [string] $URL,

        # The media type used to serialize the payloads. Supported values include `json` and `form`.
        [Parameter()]
        [ValidateSet('json', 'form')]
        [string] $ContentType,

        # If provided, the `secret` will be used as the `key` to generate the HMAC hex digest value for delivery signature headers.
        [Parameter()]
        [string] $Secret,

        # Determines whether the SSL certificate of the host for URL will be verified when delivering payloads.
        # We strongly recommend not setting this as you are subject to man-in-the-middle and other attacks.
        [Parameter()]
        [switch] $InsecureSSL,

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
        $body = @{
            url          = $URL
            content_type = $ContentType
            secret       = $Secret
            insecure_ssl = $PSBoundParameters.ContainsKey($InsecureSSL) ? ($InsecureSSL ? 1 : 0) : $null
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'Patch'
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
