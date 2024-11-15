#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '2.0.0' }

function Get-GitHubConfig {
    <#
        .SYNOPSIS
        Get a GitHub module configuration.

        .DESCRIPTION
        Get a GitHub module configuration.

        .EXAMPLE
        Get-GitHubConfig -Name DefaultUser

        Get the DefaultUser value from the GitHub module configuration.
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param (
        # The name of the configuration to get.
        [Parameter()]
        [string] $Name
    )

    if (-not $Name) {
        return Get-Context -Name $script:Config.Name -AsPlainText
    }

    Get-ContextSetting -Name $Name -Context $script:Config.Name -AsPlainText
}
