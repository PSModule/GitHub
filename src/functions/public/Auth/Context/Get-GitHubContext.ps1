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
        return Get-Context -Name "$($script:Config.Name)/*"
    }

    if ($Name) {
        return Get-Context -Name "$($script:Config.Name)/$Name"
    }

    $defaultContext = Get-ContextSetting -Name 'DefaultContext' -Context $script:Config.Name -AsPlainText
    Get-Context -Name "$($script:Config.Name)/$defaultContext"
}
