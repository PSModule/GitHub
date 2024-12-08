#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '5.0.0' }

function Get-GitHubConfig {
    <#
        .SYNOPSIS
        Get a GitHub module configuration.

        .DESCRIPTION
        Get a GitHub module configuration.

        .EXAMPLE
        Get-GitHubConfig -Name DefaultUser

        Get the DefaultUser value from the GitHub module configuration.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param(
        # The name of the configuration to get.
        [Parameter()]
        [string] $Name
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
        if (-not $Name) {
            $script:GitHub.Config
        }

        $script:GitHub.Config.$Name
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
