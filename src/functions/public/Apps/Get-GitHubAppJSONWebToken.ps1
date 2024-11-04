function Get-GitHubAppJSONWebToken {
    <#
        .SYNOPSIS
        Generates a JSON Web Token (JWT) for a GitHub App.

        .DESCRIPTION
        Generates a JSON Web Token (JWT) for a GitHub App.

        .EXAMPLE
        Get-GitHubAppJWT -ClientId 'Iv987654321' -PrivateKeyFilePath '/path/to/EXAMPLE.pem'

        Generates a JSON Web Token (JWT) for a GitHub App using the specified client ID and private key file path.

        .EXAMPLE
        Get-GitHubAppJWT -ClientId 'Iv987654321' -PrivateKey 'EXAMPLE'

        Generates a JSON Web Token (JWT) for a GitHub App using the specified client ID and private key.

        .OUTPUTS
        System.String

        .NOTES
        https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-json-web-token-jwt-for-a-github-app#example-using-powershell-to-generate-a-jwt
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines',
        '',
        Justification = 'Contains a long link.'
    )]
    [CmdletBinding(DefaultParameterSetName = 'PrivateKey')]
    [Alias('Get-GitHubAppJWT')]
    [OutputType([string])]
    param(
        # The client ID of the GitHub App.
        # Can use the GitHub App ID or the client ID.
        # Example: 'Iv23li8tyK9NUwl7rWlQ'
        # Example: '123456'
        [Parameter(Mandatory)]
        [string] $ClientId,

        # The path to the private key file of the GitHub App.
        # Example: '/path/to/private-key.pem'
        [Parameter(
            Mandatory,
            ParameterSetName = 'FilePath'
        )]
        [string] $PrivateKeyFilePath,

        # The private key of the GitHub App.
        # Example: @'
        # -----BEGIN RSA PRIVATE KEY-----
        # qwe
        # ...
        # -----END RSA PRIVATE KEY-----
        # '@
        [Parameter(
            Mandatory,
            ParameterSetName = 'PrivateKey'
        )]
        [string] $PrivateKey
    )

    if ($PrivateKeyFilePath) {
        if (-not (Test-Path -Path $PrivateKeyFilePath)) {
            throw "The private key path [$PrivateKeyFilePath] does not exist."
        }

        $PrivateKey = Get-Content -Path $PrivateKeyFilePath -Raw
    }

    $header = [Convert]::ToBase64String(
        [System.Text.Encoding]::UTF8.GetBytes(
            (
                ConvertTo-Json -InputObject @{
                    alg = 'RS256'
                    typ = 'JWT'
                }
            )
        )
    ).TrimEnd('=').Replace('+', '-').Replace('/', '_')

    $payload = [Convert]::ToBase64String(
        [System.Text.Encoding]::UTF8.GetBytes(
            (
                ConvertTo-Json -InputObject @{
                    iat = [System.DateTimeOffset]::UtcNow.AddSeconds(-10).ToUnixTimeSeconds()
                    exp = [System.DateTimeOffset]::UtcNow.AddMinutes(10).ToUnixTimeSeconds()
                    iss = $ClientId
                }
            )
        )
    ).TrimEnd('=').Replace('+', '-').Replace('/', '_')

    $rsa = [System.Security.Cryptography.RSA]::Create()
    $rsa.ImportFromPem($PrivateKey)

    $signature = [Convert]::ToBase64String(
        $rsa.SignData(
            [System.Text.Encoding]::UTF8.GetBytes("$header.$payload"),
            [System.Security.Cryptography.HashAlgorithmName]::SHA256,
            [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
        )
    ).TrimEnd('=').Replace('+', '-').Replace('/', '_')
    $jwt = "$header.$payload.$signature"
    $jwt
}
