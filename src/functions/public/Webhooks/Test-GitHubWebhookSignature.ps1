function Test-GitHubWebhookSignature {
    <#
        .SYNOPSIS
        Verifies a GitHub webhook signature using a shared secret.

        .DESCRIPTION
        This function validates the integrity and authenticity of a GitHub webhook request by comparing
        the received HMAC SHA-256 signature against a computed hash of the payload using a shared secret.
        It uses a constant-time comparison to mitigate timing attacks and returns a boolean indicating
        whether the signature is valid.

        .EXAMPLE
        Test-GitHubWebhookSignature -Secret $env:WEBHOOK_SECRET -Body $Request.RawBody -Signature $Request.Headers['X-Hub-Signature-256']

        Output:
        ```powershell
        True
        ```

        Validates the provided webhook payload against the HMAC SHA-256 signature using the given secret.

        .OUTPUTS
        bool

        .NOTES
        Returns True if the webhook signature is valid, otherwise False. Indicates whether the signature
        matches the computed value based on the payload and secret.

        .LINK
        https://psmodule.io/GitHub/Functions/Webhooks/Test-GitHubWebhookSignature/
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param (
        # The secret key used to compute the HMAC hash.
        # Example: 'mysecret'
        [Parameter(Mandatory)]
        [string] $Secret,

        # The JSON body of the GitHub webhook request.
        # This must be the compressed JSON payload received from GitHub.
        # Example: '{"action":"opened"}'
        [Parameter(Mandatory)]
        [string] $Body,

        # The signature received from GitHub to compare against.
        # Example: 'sha256=abc123...'
        [Parameter(Mandatory)]
        [string] $Signature
    )

    $keyBytes = [Text.Encoding]::UTF8.GetBytes($Secret)
    $payloadBytes = [Text.Encoding]::UTF8.GetBytes($Body)

    $hmac = [System.Security.Cryptography.HMACSHA256]::new()
    $hmac.Key = $keyBytes
    $hashBytes = $hmac.ComputeHash($payloadBytes)
    $computedSignature = 'sha256=' + (($hashBytes | ForEach-Object { $_.ToString('x2') }) -join '')

    [System.Security.Cryptography.CryptographicOperations]::FixedTimeEquals(
        [Text.Encoding]::UTF8.GetBytes($computedSignature),
        [Text.Encoding]::UTF8.GetBytes($Signature)
    )
}
