function Add-GitHubKeyVaultJWTSignature {
    <#
        .SYNOPSIS
        Adds a JWT signature using Azure Key Vault.

        .DESCRIPTION
        Signs an unsigned JWT (header.payload) using a key stored in Azure Key Vault.
        The function supports authentication via Azure CLI or Az PowerShell module and returns the signed JWT as a secure string.

        .EXAMPLE
        ```powershell
        Add-GitHubKeyVaultJWTSignature -UnsignedJWT 'header.payload' -KeyVaultKeyReference 'https://myvault.vault.azure.net/keys/mykey'
        ```

        Output:
        ```powershell
        System.Security.SecureString
        ```

        Signs the provided JWT (`header.payload`) using the specified Azure Key Vault key, returning a secure string containing the signed JWT.

        .OUTPUTS
        System.Security.SecureString

        .NOTES
        The function returns a secure string containing the fully signed JWT (header.payload.signature).
        Ensure Azure CLI or Az PowerShell is installed and authenticated before running this function.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'Used to handle secure string private keys.'
    )]
    [CmdletBinding()]
    param (
        # The unsigned JWT (header.payload) to sign.
        [Parameter(Mandatory)]
        [string] $UnsignedJWT,

        # The Azure Key Vault key URL used for signing.
        [Parameter(Mandatory)]
        [string] $KeyVaultKeyReference
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        if (Test-GitHubAzureCLI) {
            try {
                $accessToken = (az account get-access-token --resource 'https://vault.azure.net/' --output json | ConvertFrom-Json).accessToken
            } catch {
                Write-Error "Failed to get access token from Azure CLI: $_"
                return
            }
        } elseif (Test-GitHubAzPowerShell) {
            try {
                $accessToken = (Get-AzAccessToken -ResourceUrl 'https://vault.azure.net/').Token
            } catch {
                Write-Error "Failed to get access token from Az PowerShell: $_"
                return
            }
        } else {
            Write-Error 'Azure authentication is required. Please ensure you are logged in using either Azure CLI or Az PowerShell.'
            return
        }

        if ($accessToken -isnot [securestring]) {
            $accessToken = ConvertTo-SecureString -String $accessToken -AsPlainText
        }

        $hash64url = [GitHubJWTComponent]::ConvertToBase64UrlFormat(
            [System.Convert]::ToBase64String(
                [System.Security.Cryptography.SHA256]::Create().ComputeHash(
                    [System.Text.Encoding]::UTF8.GetBytes($UnsignedJWT)
                )
            )
        )

        $KeyVaultKeyReference = $KeyVaultKeyReference.TrimEnd('/')

        $params = @{
            Method         = 'POST'
            URI            = "$KeyVaultKeyReference/sign?api-version=7.4"
            Body           = @{
                alg   = 'RS256'
                value = $hash64url
            } | ConvertTo-Json
            ContentType    = 'application/json'
            Authentication = 'Bearer'
            Token          = $accessToken
        }

        $result = Invoke-RestMethod @params
        $signature = $result.value
        return (ConvertTo-SecureString -String "$UnsignedJWT.$signature" -AsPlainText)
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
