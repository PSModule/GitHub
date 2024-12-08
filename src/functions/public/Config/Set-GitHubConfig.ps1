﻿#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '5.0.0' }

function Set-GitHubConfig {
    <#
        .SYNOPSIS
        Set a GitHub module configuration.

        .DESCRIPTION
        Set a GitHub module configuration.

        .EXAMPLE
        Set-GitHubConfig -Name DefaultUser -Value 'Octocat'

        Sets the value of DefaultUser to 'Octocat' in the GitHub module configuration.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Set the access token type.
        [Parameter()]
        [string] $Name,

        # Set the access token type.
        [Parameter()]
        [string] $Value
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
        try {
            if (-not $script:Config.Initialized) {
                Initialize-GitHubConfig
                Write-Debug "Connected to context [$($script:Config.Name)]"
            }
        } catch {
            Write-Error $_
            throw 'Failed to initialize secret vault'
        }
    }

    process {
        $script:GitHub.Config.$Name = $Value
        try {
            if ($PSCmdlet.ShouldProcess('ContextSetting', 'Set')) {
                Set-Context -ID $script:GitHub.Config.ID -Context $script:GitHub.Config
            }
        } catch {
            Write-Error $_
            throw 'Failed to set GitHub module configuration.'
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
