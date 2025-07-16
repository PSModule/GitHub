# Azure Key Vault Authentication for GitHub Apps

This example demonstrates how to authenticate as a GitHub App using Azure Key Vault for JWT signing.

## Prerequisites

1. A GitHub App with a private key stored in Azure Key Vault
2. Azure authentication configured (via Azure CLI, Az PowerShell, or Managed Identity)
3. Required Azure Key Vault permissions: `keys/sign`

## Basic Usage

```powershell
# Authenticate using Azure Key Vault
Connect-GitHubAccount -ClientID "123456" -KeyVaultKey "https://my-vault.vault.azure.net/keys/my-github-app-key/latest"

# The module will automatically use Azure Key Vault for JWT signing
Get-GitHubApp  # This will work seamlessly
```

## Environment-Specific Examples

### GitHub Actions

```powershell
# In your GitHub Actions workflow
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}

- name: Connect to GitHub using KeyVault
  shell: pwsh
  run: |
    Connect-GitHubAccount -ClientID "${{ secrets.GITHUB_APP_CLIENT_ID }}" -KeyVaultKey "${{ secrets.KEYVAULT_KEY_URL }}"
    # Your GitHub API calls here
```

### Azure Automation

```powershell
# In an Azure Automation runbook
# Managed Identity is automatically used
Connect-GitHubAccount -ClientID "123456" -KeyVaultKey "https://my-vault.vault.azure.net/keys/my-github-app-key/latest"
```

### Azure Functions

```powershell
# In an Azure Function with Managed Identity
Connect-GitHubAccount -ClientID "123456" -KeyVaultKey "https://my-vault.vault.azure.net/keys/my-github-app-key/latest"
```

## Key Vault Setup

### 1. Create or Import Key

```bash
# Create a new RSA key in Key Vault
az keyvault key create --vault-name "my-vault" --name "my-github-app-key" --kty RSA --size 2048

# Or import an existing private key
az keyvault key import --vault-name "my-vault" --name "my-github-app-key" --pem-file github-app-private-key.pem
```

### 2. Grant Permissions

```bash
# Grant signing permission to a service principal
az keyvault set-policy --name "my-vault" --spn "service-principal-id" --key-permissions sign

# Or grant to a managed identity
az keyvault set-policy --name "my-vault" --object-id "managed-identity-object-id" --key-permissions sign
```

## Authentication Methods

The module automatically tries these authentication methods in order:

1. **Azure CLI** (preferred for GitHub Actions)
   - Requires: `az login` completed
   - Uses: `az keyvault key sign`

2. **Az PowerShell** (for Azure Automation/Functions)
   - Requires: Az.KeyVault module and `Connect-AzAccount`
   - Uses: `Invoke-AzKeyVaultKeyOperation`

3. **REST API with Managed Identity** (fallback)
   - Requires: Managed Identity or service principal
   - Uses: Direct REST API calls to Key Vault

## Security Benefits

- **No private key exposure**: Private key material never leaves Azure Key Vault
- **Audit trail**: All signing operations are logged in Azure Key Vault
- **Access control**: Fine-grained permissions via Azure RBAC
- **Compliance**: Meets enterprise security requirements

## Error Handling

The module provides clear error messages for common issues:

```powershell
try {
    Connect-GitHubAccount -ClientID "123456" -KeyVaultKey "https://my-vault.vault.azure.net/keys/my-key/latest"
} catch {
    Write-Error "KeyVault authentication failed: $_"
    # Check:
    # 1. Azure authentication is valid
    # 2. Key Vault permissions are correct
    # 3. Key Vault URL is valid
}
```

## Performance Considerations

- **Caching**: GitHub installation tokens are cached for up to 1 hour
- **Latency**: Azure Key Vault adds ~100-500ms per signing operation
- **Throttling**: Azure Key Vault has rate limits; tokens are cached to minimize calls

## Migration from Private Keys

```powershell
# Old approach with private key
Connect-GitHubAccount -ClientID "123456" -PrivateKey $privateKeyString

# New approach with Key Vault
Connect-GitHubAccount -ClientID "123456" -KeyVaultKey "https://my-vault.vault.azure.net/keys/my-key/latest"
```

Both approaches work identically once connected - only the authentication method differs.