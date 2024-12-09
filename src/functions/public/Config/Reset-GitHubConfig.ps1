function Reset-GitHubConfig {
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
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
    }

    process {
        try {
            if ($PSCmdlet.ShouldProcess('GitHubConfig', 'Reset')) {
                Initialize-GitHubConfig -Force
            }
        } catch {
            Write-Error $_
            throw 'Failed to reset GitHub module configuration.'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
