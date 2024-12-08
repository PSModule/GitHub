﻿#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '5.0.3' }

function Get-GitHubConfig {
    <#
        .SYNOPSIS
        Get a GitHub module configuration.

        .DESCRIPTION
        Get a GitHub module configuration.

        .EXAMPLE
        Get-GitHubConfig -Name DefaultContext

        Get the DefaultContext value from the GitHub module configuration.
    #>
    [OutputType([object], [GitHubConfig])]
    [CmdletBinding()]
    param(
        # The name of the configuration to get.
        [Parameter()]
        [string] $Name
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
        Initialize-GitHubConfig
    }

    process {
        if (-not $Name) {
            return [GitHubConfig]($script:GitHub.Config)
        }

        $script:GitHub.Config.$Name
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
