#Requires -Version 7.0
#Requires -Modules Microsoft.PowerShell.SecretManagement
#Requires -Modules Microsoft.PowerShell.SecretStore

function Initialize-SecretVault {
    <#
    .SYNOPSIS
    Initialize a secret vault.

    .DESCRIPTION
    Initialize a secret vault. If the vault does not exist, it will be created.

    .EXAMPLE
    Initialize-SecretVault -Name 'SecretStore' -Type 'Microsoft.PowerShell.SecretStore'

    Initializes a secret vault named 'SecretStore' using the 'Microsoft.PowerShell.SecretStore' module.

    .NOTES
    For more information aobut secret vaults, see https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/overview?view=ps-modules
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param (
        # The name of the secret vault.
        [Parameter()]
        [string] $Name,

        # The type of the secret vault.
        [Parameter()]
        [Alias('ModuleName')]
        [string] $Type
    )

    $secretVault = Get-SecretVault | Where-Object { $_.ModuleName -eq $Type }
    $secretVaultExists = $secretVault.count -ne 0
    Write-Verbose "A $Name exists: $secretVaultExists"
    if (-not $secretVaultExists) {
        Write-Verbose "Registering [$Name]"

        switch ($Type) {
            'Microsoft.PowerShell.SecretStore' {
                $vaultParameters = @{
                    Authentication  = 'None'
                    PasswordTimeout = -1
                    Interaction     = 'None'
                    Scope           = 'CurrentUser'
                    WarningAction   = 'SilentlyContinue'
                    Confirm         = $false
                    Force           = $true
                }
                Reset-SecretStore @vaultParameters
            }
        }

        $secretVault = @{
            Name         = $Name
            ModuleName   = $Type
            DefaultVault = $true
            Description  = 'SecretStore'
        }
        Register-SecretVault @secretVault
    }
}
