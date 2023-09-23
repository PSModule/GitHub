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

    $config = $script:Config | ConvertTo-Json -Depth 100
    Set-Secret -Name $script:Secret.Name -Secret $config -Vault $script:SecretVault.Name
}
