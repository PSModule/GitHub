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
        Remove-Context -ID 'MyContext'

        Removes the context called 'MyContext' from the vault.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The name of the context.
        [Parameter(Mandatory)]
        [string] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $null = Get-GitHubConfig
    }

    process {
        # $context variable does not exist here; we only have the string parameter $Context
        if ($PSCmdlet.ShouldProcess($Context, 'Remove context')) {
            Write-Debug ("Removing context from vault: [$Context]")
            Remove-Context -ID $Context -Vault $script:GitHub.ContextVault
        } else {
            Write-Debug ("ShouldProcess declined removal of context: [$Context]")
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '8.1.3' }
