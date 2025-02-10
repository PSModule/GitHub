﻿#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '7.0.0' }
#Requires -Modules @{ ModuleName = 'Sodium'; RequiredVersion = '2.1.2' }

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
        [Alias('Name')]
        [string] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $null = Get-GitHubConfig
    }

    process {
        $ID = "$($script:GitHub.Config.ID)/$Context"

        if ($PSCmdlet.ShouldProcess($context.Name, 'Remove context')) {
            Remove-Context -ID $ID
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
