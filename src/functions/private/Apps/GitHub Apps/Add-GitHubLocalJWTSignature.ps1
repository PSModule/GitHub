function Add-GitHubLocalJWTSignature {
    <#
        .SYNOPSIS
        Signs a JSON Web Token (JWT) using a local RSA private key.

        .DESCRIPTION
        Takes an unsigned JWT (header.payload) and adds a signature using the provided RSA private key.
        This function handles the RSA signing process and returns the complete signed JWT.

        .EXAMPLE
        Add-GitHubLocalJWTSignature -UnsignedJWT 'eyJ0eXAiOi...' -PrivateKey '--- BEGIN RSA PRIVATE KEY --- ... --- END RSA PRIVATE KEY ---'

        Adds a signature to the unsigned JWT using the provided private key.

        .OUTPUTS
        String

        .NOTES
        This function isolates the signing logic to enable support for multiple signing methods.

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App/Add-GitHubLocalJWTSignature
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        '',
        Justification = 'Used to handle secure string private keys.'
    )]
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The unsigned JWT (header.payload) to sign.
        [Parameter(Mandatory)]
        [string] $UnsignedJWT,

        # The private key of the GitHub App.
        [Parameter(Mandatory)]
        [object] $PrivateKey
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        if ($PrivateKey -is [securestring]) {
            $PrivateKey = $PrivateKey | ConvertFrom-SecureString -AsPlainText
        }

        $rsa = [System.Security.Cryptography.RSA]::Create()
        $rsa.ImportFromPem($PrivateKey)

        try {
            $signature = [Convert]::ToBase64String(
                $rsa.SignData(
                    [System.Text.Encoding]::UTF8.GetBytes($UnsignedJWT),
                    [System.Security.Cryptography.HashAlgorithmName]::SHA256,
                    [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
                )
            ).TrimEnd('=').Replace('+', '-').Replace('/', '_')
            return "$UnsignedJWT.$signature"
        } finally {
            if ($rsa) {
                $rsa.Dispose()
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
