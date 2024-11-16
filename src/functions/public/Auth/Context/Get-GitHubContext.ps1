#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '2.0.1' }

function Get-GitHubContext {
    <#
        .SYNOPSIS
        Get the current GitHub context.

        .DESCRIPTION
        Get the current GitHub context.

        .EXAMPLE
        Get-GitHubContext

        Gets the current GitHub context.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param (
        # The name of the context.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Name'
        )]
        [string] $Name,

        # List all available contexts.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ListAvailable'
        )]
        [switch] $ListAvailable
    )

    if ($ListAvailable) {
        return Get-Context -Name "$($script:Config.Name)/*" -AsPlainText
    }

    if (-not $Name) {
        $defaultContext = Get-ContextSetting -Name 'DefaultContext' -
        return Get-Context -Name $script:Config.Name
    }

    Get-Context -Name $script:Config.Name
}
