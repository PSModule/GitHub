#Requires -Modules @{ ModuleName = 'Store'; ModuleVersion = '0.3.1' }

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
    param ()

    Get-Store -Name $script:Config.Name
}
