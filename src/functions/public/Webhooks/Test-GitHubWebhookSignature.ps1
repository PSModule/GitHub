function Test-GitHubWebhookSignature {
    <#
        .SYNOPSIS
        Verifies a GitHub webhook signature using a shared secret.

        .DESCRIPTION
        This function validates the integrity and authenticity of a GitHub webhook request by comparing
        the received HMAC signature against a computed hash of the payload using a shared secret.
        It uses the SHA-256 algorithm and employs a constant-time comparison to mitigate
        timing attacks. The function returns a boolean indicating whether the signature is valid.

        .EXAMPLE
        ```powershell
        Test-GitHubWebhookSignature -Secret $env:WEBHOOK_SECRET -Body $Request.RawBody -Signature $Request.Headers['X-Hub-Signature-256']
        ```

        Output:
        ```powershell
        True
        ```

        Validates the provided webhook payload against the HMAC SHA-256 signature using the given secret.

        .EXAMPLE
        ```powershell
        Test-GitHubWebhookSignature -Secret $env:WEBHOOK_SECRET -Request $Request
        ```

        Output:
        ```powershell
        True
        ```

        Validates the webhook request using the entire request object, automatically extracting the body and signature.

        .OUTPUTS
        bool

        .NOTES
        Returns True if the webhook signature is valid, otherwise False. Indicates whether the signature
        matches the computed value based on the payload and secret.

        .LINK
        https://psmodule.io/GitHub/Functions/Webhooks/Test-GitHubWebhookSignature

        .NOTES
        [Validating Webhook Deliveries | GitHub Docs](https://docs.github.com/webhooks/using-webhooks/validating-webhook-deliveries)
        [Webhook events and payloads | GitHub Docs](https://docs.github.com/en/webhooks/webhook-events-and-payloads)
    #>
    [OutputType([bool])]
    [CmdletBinding(DefaultParameterSetName = 'ByBody')]
    param (
        # The secret key used to compute the HMAC hash.
        # Example: 'mysecret'
        [Parameter(Mandatory)]
        [string] $Secret,

        # The JSON body of the GitHub webhook request.
        # This must be the compressed JSON payload received from GitHub.
        # Example: '{"action":"opened"}'
        [Parameter(Mandatory, ParameterSetName = 'ByBody')]
        [string] $Body,

        # The signature received from GitHub to compare against.
        # Example: 'sha256=abc123...'
        [Parameter(Mandatory, ParameterSetName = 'ByBody')]
        [string] $Signature,

        # The entire request object containing RawBody and Headers.
        # Used in Azure Function Apps or similar environments.
        [Parameter(Mandatory, ParameterSetName = 'ByRequest')]
        [PSObject] $Request
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        # Handle parameter sets
        if ($PSCmdlet.ParameterSetName -eq 'ByRequest') {
            $Body = $Request.RawBody
            $Signature = $Request.Headers['X-Hub-Signature-256']

            # If signature not found, throw an error
            if (-not $Signature) {
                throw "No webhook signature found in request headers. Expected 'X-Hub-Signature-256' for SHA256 algorithm."
            }
        }

        $keyBytes = [Text.Encoding]::UTF8.GetBytes($Secret)
        $payloadBytes = [Text.Encoding]::UTF8.GetBytes($Body)

        # Create HMAC SHA256 object
        $hmac = [System.Security.Cryptography.HMACSHA256]::new()
        $algorithmPrefix = 'sha256='

        $hmac.Key = $keyBytes
        $hashBytes = $hmac.ComputeHash($payloadBytes)
        $computedSignature = $algorithmPrefix + (($hashBytes | ForEach-Object { $_.ToString('x2') }) -join '')

        # Dispose of the HMAC object
        $hmac.Dispose()

        [System.Security.Cryptography.CryptographicOperations]::FixedTimeEquals(
            [Text.Encoding]::UTF8.GetBytes($computedSignature),
            [Text.Encoding]::UTF8.GetBytes($Signature)
        )
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

