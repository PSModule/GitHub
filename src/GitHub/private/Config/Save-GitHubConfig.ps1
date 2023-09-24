#Requires -Version 7.0
#Requires -Modules Microsoft.PowerShell.SecretManagement

function Save-GitHubConfig {
    <#
        .SYNOPSIS
        Save the GitHub configuration to the configuration store.

        .DESCRIPTION
        Save the GitHub configuration to the configuration store.

        .EXAMPLE
        Save-GitHubConfig

        Saves the GitHub configuration to the configuration store.
    #>
    [Alias('Save-GHConfig')]
    [OutputType([void])]
    [CmdletBinding()]
    param()

    Set-Secret -Name $script:SecretVault.Secret.Name -Secret $script:Config -Vault $script:SecretVault.Name
}
