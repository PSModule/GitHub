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
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        $Name
    )

    Restore-GitHubConfig
    $script:Config
}
