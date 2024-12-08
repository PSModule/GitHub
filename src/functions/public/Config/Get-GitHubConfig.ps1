#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '4.0.5' }

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
    [OutputType([void])]
    [CmdletBinding()]
    param(
        # The name of the configuration to get.
        [Parameter()]
        [string] $Name
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
        $moduleContext = Get-Context -ID $script:Config.Name
    }

    process {
        if (-not $Name) {
            return $moduleContext
        }

        $moduleContext.$Name
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
