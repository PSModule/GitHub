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
        Test-GitHubWebhookSignature -Secret 'mysecret' -Body '{"action":"opened"}' -Signature 'sha256=abc123...'

        Output:
        ```powershell
        True
        ```

        Validates the provided webhook payload against the HMAC SHA-256 signature using the given secret.

        .OUTPUTS
        bool. Returns True if the webhook signature is valid, otherwise False. Indicates whether the signature
        matches the computed value based on the payload and secret.

        .LINK
        https://psmodule.io/GitHub/Functions/Webhooks/Test-GitHubWebhookSignature

        .LINK
        https://docs.github.com/en/enterprise-cloud@latest/webhooks/using-webhooks/validating-webhook-deliveries
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param (
        # The secret key used to compute the HMAC hash.
        [Parameter(Mandatory)]
        [string] $Secret,

        # The JSON body of the GitHub webhook request.
        # This must be the compressed JSON payload received from GitHub.
        [Parameter(Mandatory)]
        [string] $Body,

        # The signature received from GitHub to compare against.
        [Parameter(Mandatory)]
        [string] $Signature
    )

    # Compute HMAC SHA-256 hash using the secret and payload
    $keyBytes = [Text.Encoding]::UTF8.GetBytes($Secret)
    $payloadBytes = [Text.Encoding]::UTF8.GetBytes($Body)

    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = $keyBytes
    $hashBytes = $hmac.ComputeHash($payloadBytes)

    # Convert hash to hex string
    $computedSignature = 'sha256=' + (($hashBytes | ForEach-Object { $_.ToString('x2') }) -join '')

    # Use constant-time comparison to avoid timing attacks
    $valid = [System.Security.Cryptography.CryptographicOperations]::FixedTimeEquals(
        [Text.Encoding]::UTF8.GetBytes($computedSignature),
        [Text.Encoding]::UTF8.GetBytes($Signature)
    )
    return $valid
}
