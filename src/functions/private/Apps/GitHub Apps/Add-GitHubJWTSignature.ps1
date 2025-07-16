function Add-GitHubJWTSignature {
    <#
        .SYNOPSIS
        Signs a JSON Web Token (JWT) using either a local RSA private key or Azure Key Vault.

        .DESCRIPTION
        Takes an unsigned JWT (header.payload) and adds a signature using either:
        - A provided RSA private key (local signing)
        - An Azure Key Vault key reference (remote signing)

        When a KeyVaultKey is provided, the function will use Azure Key Vault for signing instead of local RSA operations.

        .EXAMPLE
        Add-GitHubJWTSignature -UnsignedJWT 'eyJ0eXAiOi...' -PrivateKey '--- BEGIN RSA PRIVATE KEY --- ... --- END RSA PRIVATE KEY ---'

        Adds a signature to the unsigned JWT using the provided private key.

        .EXAMPLE
        Add-GitHubJWTSignature -UnsignedJWT 'eyJ0eXAiOi...' -KeyVaultKey 'https://vault.vault.azure.net/keys/mykey/version'

        Adds a signature to the unsigned JWT using Azure Key Vault signing.

        .OUTPUTS
        String

        .NOTES
        This function supports both local RSA signing and remote Azure Key Vault signing for enhanced security.

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

        # The private key of the GitHub App.
        [Parameter(
            Mandatory,
            ParameterSetName = 'PrivateKey'
        )]
        [object] $PrivateKey,

        # Azure Key Vault key reference for JWT signing.
        [Parameter(
            Mandatory,
            ParameterSetName = 'KeyVault'
        )]
        [string] $KeyVaultKey
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $dataToSign = [System.Text.Encoding]::UTF8.GetBytes($UnsignedJWT)

        if ($PSCmdlet.ParameterSetName -eq 'KeyVault') {
            Write-Verbose 'Signing JWT using Azure Key Vault'
            try {
                $signatureBytes = Invoke-AzureKeyVaultSign -KeyVaultKey $KeyVaultKey -Data $dataToSign
                $signature = [Convert]::ToBase64String($signatureBytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
                return "$UnsignedJWT.$signature"
            } catch {
                Write-Error "Failed to sign JWT using Azure Key Vault: $_"
                throw
            }
        } else {
            Write-Verbose 'Signing JWT using local private key'
            if ($PrivateKey -is [securestring]) {
                $PrivateKey = $PrivateKey | ConvertFrom-SecureString -AsPlainText
            }

            $rsa = [System.Security.Cryptography.RSA]::Create()
            $rsa.ImportFromPem($PrivateKey)

            try {
                $signature = [Convert]::ToBase64String(
                    $rsa.SignData(
                        $dataToSign,
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
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
