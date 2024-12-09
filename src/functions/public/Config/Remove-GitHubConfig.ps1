﻿#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '5.0.3' }

function Remove-GitHubConfig {
    <#
        .SYNOPSIS
        Remove a GitHub module configuration.

        .DESCRIPTION
        Remove a GitHub module configuration.

        .EXAMPLE
        Remove-GitHubConfig -Name DefaultUser

        Removes the 'DefaultUser' item in the GitHub module configuration.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Set the access token type.
        [Parameter()]
        [string] $Name
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
        Initialize-GitHubConfig
    }

    process {
        try {
            if ($PSCmdlet.ShouldProcess('ContextSetting', 'Remove')) {
                $script:GitHub.Config.$Name = $null
            }
        } catch {
            Write-Error $_
            Write-Error (Get-PSCallStack | Format-Table | Out-String)
            throw 'Failed to connect to GitHub.'
        }
        Set-Context -ID $script:GitHub.Config.ID -Context $script:GitHub.Config
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
