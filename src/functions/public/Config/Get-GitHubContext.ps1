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
    param (
        # The name of the context.
        [Parameter(Mandatory)]
        [string] $Name
    )

    Get-Store -Name $script:Config.Name
}
