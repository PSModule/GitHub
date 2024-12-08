#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '4.0.5' }

filter Remove-GitHubContext {
    <#
        .SYNOPSIS
        Removes a context from the context vault.

        .DESCRIPTION
        This function removes a context from the vault. It supports removing a single context by name,
        multiple contexts using wildcard patterns, and can also accept input from the pipeline.
        If the specified context(s) exist, they will be removed from the vault.

        .EXAMPLE
        Remove-Context

        Removes all contexts from the vault.

        .EXAMPLE
        Remove-Context -ID 'MySecret'

        Removes the context called 'MySecret' from the vault.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The name of the context.
        [Parameter(Mandatory)]
        [Alias('Name')]
        [string] $Context
    )

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    $ID = "$($script:Config.Name)/$Context"

    if ($PSCmdlet.ShouldProcess('Remove-Secret', $context.Name)) {
        Remove-Context -ID $ID
    }

    Write-Verbose "[$commandName] - End"
}
