function Get-GitHubConfigTemplate {
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
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param ()

    $script:ConfigTemplate
}
