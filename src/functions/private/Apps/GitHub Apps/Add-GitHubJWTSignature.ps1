function Add-GitHubJWTSignature {
    <#
        .SYNOPSIS
        Signs a JSON Web Token (JWT) using a local RSA private key.

        .DESCRIPTION
        Takes an unsigned JWT (header.payload) and adds a signature using the provided RSA private key.
        This function handles the RSA signing process and returns the complete signed JWT.

        .EXAMPLE
        Add-GitHubJWTSignature -UnsignedJWT 'eyJ0eXAiOi...' -PrivateKey '--- BEGIN RSA PRIVATE KEY --- ... --- END RSA PRIVATE KEY ---'

        Adds a signature to the unsigned JWT using the provided private key.

        .EXAMPLE
        Add-GitHubJWTSignature -UnsignedJWT 'eyJ0eXAiOi...' -PrivateKeyFilePath '/path/to/private-key.pem'

        Adds a signature to the unsigned JWT using the private key from the specified file.

        .OUTPUTS
        String

        .NOTES
        This function isolates the signing logic to enable support for multiple signing methods.

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App/Add-GitHubJWTSignature
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        '',
        Justification = 'Used to handle secure string private keys.'
    )]
    [CmdletBinding(DefaultParameterSetName = 'PrivateKey')]
    [OutputType([string])]
    param(
        # The unsigned JWT (header.payload) to sign.
        [Parameter(Mandatory)]
        [string] $UnsignedJWT,

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
        # Load private key from file if path provided
        if ($PrivateKeyFilePath) {
            if (-not (Test-Path -Path $PrivateKeyFilePath)) {
                throw "The private key path [$PrivateKeyFilePath] does not exist."
            }
            $PrivateKey = Get-Content -Path $PrivateKeyFilePath -Raw
        }

        # Convert SecureString to plain text if needed
        if ($PrivateKey -is [securestring]) {
            $PrivateKey = $PrivateKey | ConvertFrom-SecureString -AsPlainText
        }

        # Create RSA instance and import the private key
        $rsa = [System.Security.Cryptography.RSA]::Create()
        $rsa.ImportFromPem($PrivateKey)

        try {
            # Sign the unsigned JWT
            $signature = [Convert]::ToBase64String(
                $rsa.SignData(
                    [System.Text.Encoding]::UTF8.GetBytes($UnsignedJWT),
                    [System.Security.Cryptography.HashAlgorithmName]::SHA256,
                    [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
                )
            ).TrimEnd('=').Replace('+', '-').Replace('/', '_')

            # Return the complete signed JWT
            return "$UnsignedJWT.$signature"
        } finally {
            # Clean up RSA instance
            if ($rsa) {
                $rsa.Dispose()
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}