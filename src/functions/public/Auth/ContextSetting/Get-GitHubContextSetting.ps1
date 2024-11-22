#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '3.0.3' }

function Get-GitHubContextSetting {
    <#
        .SYNOPSIS
        Get a module configuration value.

        .DESCRIPTION
        Get a named configuration value from the GitHub config.

        .EXAMPLE
        Get-GitHubContextSetting -Name DefaultUser

        Get the current GitHub configuration for the DefaultUser.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param(
        # Choose a configuration name to get.
        [Parameter()]
        [string] $Name,

        # The name of the context.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $contextID = "$($script:Config.Name)/$Context"

    if (-not $Name) {
        Get-Context -ID $contextID
    }

    Get-ContextSetting -Name $Name -ID $contextID
}
