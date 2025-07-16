#!/usr/bin/env pwsh
<#
.SYNOPSIS
Demo script showcasing Azure Key Vault authentication for GitHub Apps.

.DESCRIPTION
This script demonstrates the new KeyVault-based authentication feature for GitHub Apps.
It shows the difference between traditional private key authentication and the new
Azure Key Vault-based approach.

.EXAMPLE
./examples/KeyVaultDemo.ps1

Runs the demo showing both authentication methods.
#>

param(
    # Your GitHub App Client ID
    [Parameter()]
    [string] $ClientID = "123456",
    
    # Your Azure Key Vault key URL
    [Parameter()]
    [string] $KeyVaultKey = "https://my-vault.vault.azure.net/keys/my-github-app-key/latest",
    
    # Show verbose output
    [switch] $ShowVerbose
)

if ($ShowVerbose) {
    $VerbosePreference = 'Continue'
}

Write-Host "🚀 Azure Key Vault Authentication Demo for GitHub Apps" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

# Import the module (in real scenarios, this would be: Import-Module GitHub)
Write-Host "`n📦 Loading GitHub PowerShell module..." -ForegroundColor Yellow
try {
    . "$PSScriptRoot/../src/functions/public/Auth/Connect-GitHubAccount.ps1"
    Write-Host "✅ Module loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to load module: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n🔐 Traditional Authentication (Private Key)" -ForegroundColor Cyan
Write-Host "--------------------------------------------" -ForegroundColor Cyan

$traditionalExample = @"
# Traditional approach - private key as string/file
Connect-GitHubAccount -ClientID "123456" -PrivateKey `$privateKeyString

# Issues:
# ❌ Private key must be stored securely
# ❌ Key material exposed in memory/logs
# ❌ Difficult to rotate keys
# ❌ Limited audit capabilities
"@

Write-Host $traditionalExample -ForegroundColor White

Write-Host "`n🔑 New Azure Key Vault Authentication" -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan

$keyVaultExample = @"
# New approach - Azure Key Vault reference
Connect-GitHubAccount -ClientID "$ClientID" -KeyVaultKey "$KeyVaultKey"

# Benefits:
# ✅ Private key never leaves Azure Key Vault
# ✅ Full audit trail of all signing operations
# ✅ Fine-grained access control via Azure RBAC
# ✅ Easy key rotation and management
# ✅ Supports multiple authentication methods
"@

Write-Host $keyVaultExample -ForegroundColor White

Write-Host "`n🛠️ How It Works" -ForegroundColor Cyan
Write-Host "---------------" -ForegroundColor Cyan

$howItWorks = @"
1. You call Connect-GitHubAccount with -KeyVaultKey parameter
2. Module detects KeyVault authentication and stores the key reference
3. When a JWT is needed, the module:
   a. Creates the unsigned JWT (header.payload)
   b. Sends the data to Azure Key Vault for signing
   c. Returns the complete signed JWT
4. The signed JWT is used for GitHub API authentication

Authentication methods tried in order:
• Azure CLI (az keyvault key sign) - preferred for GitHub Actions
• Az PowerShell (Invoke-AzKeyVaultKeyOperation) - for Azure Automation/Functions  
• REST API with Managed Identity - fallback option
"@

Write-Host $howItWorks -ForegroundColor White

Write-Host "`n🌍 Environment Examples" -ForegroundColor Cyan
Write-Host "-----------------------" -ForegroundColor Cyan

Write-Host "`n📋 GitHub Actions:" -ForegroundColor Yellow
$actionsExample = @"
steps:
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: `${{ secrets.AZURE_CREDENTIALS }}

- name: GitHub Authentication
  run: |
    Connect-GitHubAccount -ClientID "`${{ secrets.GITHUB_APP_CLIENT_ID }}" \
                         -KeyVaultKey "`${{ secrets.KEYVAULT_KEY_URL }}"
"@
Write-Host $actionsExample -ForegroundColor Gray

Write-Host "`n🤖 Azure Automation:" -ForegroundColor Yellow
$automationExample = @"
# Managed Identity automatically used
Connect-GitHubAccount -ClientID "123456" \
                     -KeyVaultKey "https://vault.vault.azure.net/keys/key/version"
"@
Write-Host $automationExample -ForegroundColor Gray

Write-Host "`n⚡ Azure Functions:" -ForegroundColor Yellow
$functionsExample = @"
# In a PowerShell Azure Function with Managed Identity
Connect-GitHubAccount -ClientID "123456" \
                     -KeyVaultKey "https://vault.vault.azure.net/keys/key/version"
"@
Write-Host $functionsExample -ForegroundColor Gray

Write-Host "`n🔒 Security Setup" -ForegroundColor Cyan
Write-Host "-----------------" -ForegroundColor Cyan

$securitySetup = @"
1. Create/import your GitHub App private key in Azure Key Vault:
   az keyvault key import --vault-name "my-vault" --name "github-key" --pem-file private-key.pem

2. Grant minimal permissions (only 'keys/sign'):
   az keyvault set-policy --name "my-vault" --spn "<service-principal-id>" --key-permissions sign

3. Use the Key Vault URL in your authentication:
   https://my-vault.vault.azure.net/keys/github-key/latest

4. Enable auditing (recommended):
   - Azure Key Vault logs all signing operations
   - Monitor access via Azure Monitor/Log Analytics
"@

Write-Host $securitySetup -ForegroundColor White

Write-Host "`n✨ Try It Yourself" -ForegroundColor Cyan
Write-Host "------------------" -ForegroundColor Cyan

Write-Host "1. Set up your Azure Key Vault with your GitHub App private key" -ForegroundColor White
Write-Host "2. Ensure you have Azure authentication configured" -ForegroundColor White
Write-Host "3. Run: Connect-GitHubAccount -ClientID 'your-client-id' -KeyVaultKey 'your-vault-url'" -ForegroundColor White
Write-Host "4. Use GitHub API commands as normal - JWT signing happens automatically!" -ForegroundColor White

Write-Host "`n🎉 Demo Complete!" -ForegroundColor Green
Write-Host "The KeyVault authentication feature is now ready for production use." -ForegroundColor Green
Write-Host "For more details, see: examples/KeyVaultAuthentication.md" -ForegroundColor Yellow