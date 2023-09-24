function Get-GitHubConfig {
    <#
        .SYNOPSIS
        Get the current GitHub configuration.

        .DESCRIPTION
        Get the current GitHub configuration.
        The configuration is first loaded from the configuration file.

        .EXAMPLE
        Get-GitHubConfig

        Returns the current GitHub configuration.

    #>
    [Alias('Get-GHConfig')]
    [Alias('GGHC')]
    [OutputType([object])]
    [CmdletBinding()]
    param (
        [string] $Name,
        [switch] $AsPlainText
    )
    $prefix = $script:SecretVault.Prefix
    $Name = "$prefix$Name"
    Get-Secret -Name $Name -Vault $script:SecretVault.Name -AsPlainText:$AsPlainText
}
