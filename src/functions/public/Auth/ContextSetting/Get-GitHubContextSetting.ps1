#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '4.0.0' }

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

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    $ID = "$($script:Config.Name)/$Context"

    if (-not $Name) {
        Get-Context -ID $ID
    }

    Get-ContextSetting -Name $Name -ID $ID

    Write-Verbose "[$commandName] - End"
}
