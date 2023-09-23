function Get-GitHubConfig {
    <#
        .SYNOPSIS
        Get the current GitHub configuration.

        .DESCRIPTION
        Get the current GitHub configuration.
        If the Refresh switch is used, the configuration will be refreshed from the configuration file.

        .EXAMPLE
        Get-GitHubConfig

        Returns the current GitHub configuration.

        .EXAMPLE
        Get-GitHubConfig -Refresh

        Refreshes the current GitHub configuration from the configuration store beofre returning it.
    #>
    [Alias('Get-GHConfig')]
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        # Refresh the configuration from the configuration store before returning it.
        [Parameter()]
        [switch] $Refresh
    )

    if ($Refresh) {
        Restore-GitHubConfig
    }

    $script:Config
}
