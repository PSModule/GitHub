function Get-GitHubAppJSONWebToken {
    <#
        .SYNOPSIS
        Generates a JSON Web Token (JWT) for a GitHub App.

        .DESCRIPTION
        Generates a JSON Web Token (JWT) for a GitHub App.

        .EXAMPLE
        Get-GitHubAppJWT -ClientId 'Iv987654321' -PrivateKeyFilePath '/path/to/private-key.pem'

        Generates a JSON Web Token (JWT) for a GitHub App using the specified client ID and private key file path.

        .EXAMPLE
        Get-GitHubAppJWT -ClientId 'Iv987654321' -PrivateKey '--- BEGIN RSA PRIVATE KEY --- ... --- END RSA PRIVATE KEY ---'

        Generates a JSON Web Token (JWT) for a GitHub App using the specified client ID and private key.

        .OUTPUTS
        System.String

        .NOTES
        [Generating a JSON Web Token (JWT) for a GitHub App | GitHub Docs](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-json-web-token-jwt-for-a-github-app#example-using-powershell-to-generate-a-jwt)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines',
        '',
        Justification = 'Contains a long link.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        '',
        Justification = 'Generated JWT is a plaintext string.'
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
        [object] $PrivateKey
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
    }

    process {
        if ($PrivateKeyFilePath) {
            if (-not (Test-Path -Path $PrivateKeyFilePath)) {
                throw "The private key path [$PrivateKeyFilePath] does not exist."
            }

            $PrivateKey = Get-Content -Path $PrivateKeyFilePath -Raw
        }

        if ($PrivateKey -is [securestring]) {
            $PrivateKey = $PrivateKey | ConvertFrom-SecureString -AsPlainText
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

        $iat = [System.DateTimeOffset]::UtcNow.AddSeconds(-10).ToUnixTimeSeconds()
        $exp = [System.DateTimeOffset]::UtcNow.AddMinutes(10).ToUnixTimeSeconds()
        $payload = [Convert]::ToBase64String(
            [System.Text.Encoding]::UTF8.GetBytes(
                (
                    ConvertTo-Json -InputObject @{
                        iat = $iat
                        exp = $exp
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
        [pscustomobject]@{
            Token     = ConvertTo-SecureString -String $jwt -AsPlainText
            IssuedAt  = $iat
            ExpiresAt = $exp
            Issuer    = $ClientId
        }
    }

    end {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - End"
    }

    clean {
        Remove-Variable -Name jwt -ErrorAction SilentlyContinue
        Remove-Variable -Name rsa -ErrorAction SilentlyContinue
        Remove-Variable -Name signature -ErrorAction SilentlyContinue
        [System.GC]::Collect()
    }
}
