#Requires -Version 7.0
#Requires -Modules Microsoft.PowerShell.SecretManagement

function Restore-GitHubConfig {
    <#
        .SYNOPSIS
        Restore the GitHub configuration from the configuration store.

        .DESCRIPTION
        Restore the GitHub configuration from the configuration store.

        .EXAMPLE
        Restore-GitHubConfig

        Restores the GitHub configuration from the configuration store.
    #>
    [Alias('Load-GitHubConfig')]
    [Alias('Load-GHConfig')]
    [Alias('Restore-GHConfig')]
    [OutputType([void])]
    [CmdletBinding()]
    param()

    $vault = Get-SecretVault -Name $script:SecretVault.Name
    $vaultExists = $vault.count -eq 1
    if ($vaultExists) {
        $secretExists = Get-SecretInfo -Name $script:Secret.Name -Vault $script:SecretVault.Name
        if ($secretExists) {
            $script:Config = Get-Secret -Name $script:Secret.Name -AsPlainText -Vault $script:SecretVault.Name | ConvertFrom-Json
        } else {
            Write-Warning "Unable to restore configuration."
            Write-Warning "The secret [$($script:Secret.Name)] does not exist in the vault [$($script:SecretVault.Name)]."
        }
    } else {
        Write-Warning "Unable to restore configuration."
        Write-Warning "The vault [$($script:SecretVault.Name)] does not exist."
    }
}
