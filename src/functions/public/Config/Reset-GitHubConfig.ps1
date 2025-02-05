﻿function Reset-GitHubConfig {
    <#
        .SYNOPSIS
        Re-initializes the GitHub module configuration.

        .DESCRIPTION
        Re-initializes the GitHub module configuration.

        .EXAMPLE
        Reset-GitHubConfig

        Re-initializes the GitHub module configuration.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        if ($PSCmdlet.ShouldProcess('GitHubConfig', 'Reset')) {
            Initialize-GitHubConfig -Force
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
