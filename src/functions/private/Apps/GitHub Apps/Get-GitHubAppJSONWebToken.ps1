﻿function Get-GitHubAppJSONWebToken {
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
        GitHubJsonWebToken

        .NOTES
        [Generating a JSON Web Token (JWT) for a GitHub App | GitHub Docs](https://docs.github.com/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-json-web-token-jwt-for-a-github-app#example-using-powershell-to-generate-a-jwt)

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App/Get-GitHubAppJSONWebToken
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
    [OutputType([GitHubJsonWebToken])]
    param(
        # The client ID of the GitHub App.
        # Can use the GitHub App ID or the client ID.
        [Parameter(Mandatory)]
        [string] $ClientId,

        # The path to the private key file of the GitHub App.
        [Parameter(
            Mandatory,
            ParameterSetName = 'FilePath'
        )]
        [string] $PrivateKeyFilePath,

        # The private key of the GitHub App.
        [Parameter(
            Mandatory,
            ParameterSetName = 'PrivateKey'
        )]
        [object] $PrivateKey
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
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

        $iat = [System.DateTimeOffset]::UtcNow.AddSeconds(-$script:GitHub.Config.JwtTimeTolerance).ToUnixTimeSeconds()
        $exp = [System.DateTimeOffset]::UtcNow.AddSeconds($script:GitHub.Config.JwtTimeTolerance).ToUnixTimeSeconds()
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
        [GitHubJsonWebToken]@{
            Token     = ConvertTo-SecureString -String $jwt -AsPlainText
            IssuedAt  = [DateTime]::UnixEpoch.AddSeconds($iat)
            ExpiresAt = [DateTime]::UnixEpoch.AddSeconds($exp)
            Issuer    = $ClientId
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }

    clean {
        Remove-Variable -Name jwt -ErrorAction SilentlyContinue
        Remove-Variable -Name rsa -ErrorAction SilentlyContinue
        Remove-Variable -Name signature -ErrorAction SilentlyContinue
        [System.GC]::Collect()
    }
}
