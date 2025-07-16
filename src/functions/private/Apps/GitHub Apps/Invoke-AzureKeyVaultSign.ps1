function Invoke-AzureKeyVaultSign {
    <#
        .SYNOPSIS
        Signs data using an Azure Key Vault key.

        .DESCRIPTION
        Signs data using an Azure Key Vault key via multiple authentication methods:
        - Azure CLI (preferred for GitHub Actions)
        - Az PowerShell module (for Azure Automation/Functions)
        - Direct REST API calls (fallback option)

        .EXAMPLE
        Invoke-AzureKeyVaultSign -KeyVaultKey 'https://vault.vault.azure.net/keys/mykey/version' -Data $dataToSign

        Signs the provided data using the specified Azure Key Vault key.

        .OUTPUTS
        byte[]

        .NOTES
        This function automatically detects the best available authentication method and uses it.
        Authentication methods are tried in the following order:
        1. Azure CLI (if available and authenticated)
        2. Az PowerShell (if module is available and authenticated)
        3. REST API with managed identity (as fallback)

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App/Invoke-AzureKeyVaultSign
    #>
    [CmdletBinding()]
    [OutputType([byte[]])]
    param(
        # The Azure Key Vault key URL.
        # Example: 'https://vault-name.vault.azure.net/keys/key-name/key-version'
        [Parameter(Mandatory)]
        [string] $KeyVaultKey,

        # The data to sign as a byte array.
        [Parameter(Mandatory)]
        [byte[]] $Data
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        # Parse the Key Vault URL to extract components
        if ($KeyVaultKey -notmatch '^https://([^.]+)\.vault\.azure\.net/keys/([^/]+)/?(.*)$') {
            throw "Invalid Key Vault key URL format: $KeyVaultKey"
        }
        $vaultName = $Matches[1]
        $keyName = $Matches[2]
        $keyVersion = $Matches[3]

        Write-Verbose "Vault: $vaultName, Key: $keyName, Version: $keyVersion"

        # Convert data to base64 for API calls
        $base64Data = [Convert]::ToBase64String($Data)

        # Try Azure CLI first (preferred for GitHub Actions)
        $signature = Invoke-KeyVaultSignWithAzCli -VaultName $vaultName -KeyName $keyName -KeyVersion $keyVersion -Data $base64Data
        if ($signature) {
            Write-Verbose 'Successfully signed using Azure CLI'
            return $signature
        }

        # Try Az PowerShell module (for Azure Automation/Functions)
        $signature = Invoke-KeyVaultSignWithAzPowerShell -VaultName $vaultName -KeyName $keyName -KeyVersion $keyVersion -Data $base64Data
        if ($signature) {
            Write-Verbose 'Successfully signed using Az PowerShell'
            return $signature
        }

        # Try REST API with managed identity (fallback)
        $signature = Invoke-KeyVaultSignWithRestApi -KeyVaultKey $KeyVaultKey -Data $base64Data
        if ($signature) {
            Write-Verbose 'Successfully signed using REST API'
            return $signature
        }

        throw 'Failed to sign data using Azure Key Vault. Ensure you are authenticated with Azure and have the required permissions.'
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

function Invoke-KeyVaultSignWithAzCli {
    [CmdletBinding()]
    [OutputType([byte[]])]
    param(
        [string] $VaultName,
        [string] $KeyName,
        [string] $KeyVersion,
        [string] $Data
    )

    try {
        # Check if Azure CLI is available and authenticated
        $null = & az account show --output json 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Verbose 'Azure CLI not authenticated or not available'
            return $null
        }

        Write-Verbose 'Using Azure CLI for Key Vault signing'

        # Build the command
        $azCommand = @('az', 'keyvault', 'key', 'sign')
        $azCommand += @('--vault-name', $VaultName)
        $azCommand += @('--name', $KeyName)
        if ($KeyVersion) {
            $azCommand += @('--version', $KeyVersion)
        }
        $azCommand += @('--algorithm', 'RS256')
        $azCommand += @('--value', $Data)
        $azCommand += @('--output', 'json')

        # Execute the command
        $result = & $azCommand[0] $azCommand[1..($azCommand.Length-1)] 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Verbose "Azure CLI sign command failed with exit code: $LASTEXITCODE"
            return $null
        }

        $jsonResult = $result | ConvertFrom-Json
        return [Convert]::FromBase64String($jsonResult.result)
    } catch {
        Write-Verbose "Azure CLI signing failed: $_"
        return $null
    }
}

function Invoke-KeyVaultSignWithAzPowerShell {
    [CmdletBinding()]
    [OutputType([byte[]])]
    param(
        [string] $VaultName,
        [string] $KeyName,
        [string] $KeyVersion,
        [string] $Data
    )

    try {
        # Check if Az.KeyVault module is available
        if (-not (Get-Module -Name Az.KeyVault -ListAvailable)) {
            Write-Verbose 'Az.KeyVault module not available'
            return $null
        }

        # Check if connected to Azure
        $context = Get-AzContext -ErrorAction SilentlyContinue
        if (-not $context) {
            Write-Verbose 'Not connected to Azure via Az PowerShell'
            return $null
        }

        Write-Verbose 'Using Az PowerShell for Key Vault signing'

        # Build parameters for Invoke-AzKeyVaultKeyOperation
        $params = @{
            VaultName = $VaultName
            KeyName = $KeyName
            Algorithm = 'RS256'
            Value = $Data
            Operation = 'Sign'
        }
        if ($KeyVersion) {
            $params.KeyVersion = $KeyVersion
        }

        $result = Invoke-AzKeyVaultKeyOperation @params
        return [Convert]::FromBase64String($result.Result)
    } catch {
        Write-Verbose "Az PowerShell signing failed: $_"
        return $null
    }
}

function Invoke-KeyVaultSignWithRestApi {
    [CmdletBinding()]
    [OutputType([byte[]])]
    param(
        [string] $KeyVaultKey,
        [string] $Data
    )

    try {
        # Get access token for Key Vault
        $accessToken = Get-AzureAccessToken
        if (-not $accessToken) {
            Write-Verbose 'Could not obtain Azure access token'
            return $null
        }

        Write-Verbose 'Using REST API for Key Vault signing'

        # Prepare the request
        $signUrl = "$KeyVaultKey/sign?api-version=7.3"
        $headers = @{
            'Authorization' = "Bearer $accessToken"
            'Content-Type' = 'application/json'
        }
        $body = @{
            alg = 'RS256'
            value = $Data
        } | ConvertTo-Json

        # Make the REST API call
        $response = Invoke-RestMethod -Uri $signUrl -Method POST -Headers $headers -Body $body
        return [Convert]::FromBase64String($response.value)
    } catch {
        Write-Verbose "REST API signing failed: $_"
        return $null
    }
}

function Get-AzureAccessToken {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    try {
        # Try to get token from managed identity
        $metadataUri = 'http://169.254.169.254/metadata/identity/oauth2/token'
        $params = @{
            Uri = $metadataUri
            Method = 'GET'
            Headers = @{ 'Metadata' = 'true' }
            Body = @{
                'api-version' = '2018-02-01'
                'resource' = 'https://vault.azure.net'
            }
            TimeoutSec = 5
        }

        $response = Invoke-RestMethod @params
        return $response.access_token
    } catch {
        Write-Verbose "Failed to get managed identity token: $_"

        # Try Az PowerShell if available
        try {
            if (Get-Module -Name Az.Accounts -ListAvailable) {
                $token = Get-AzAccessToken -ResourceUrl 'https://vault.azure.net' -ErrorAction SilentlyContinue
                return $token.Token
            }
        } catch {
            Write-Verbose "Failed to get token via Az PowerShell: $_"
        }

        return $null
    }
}