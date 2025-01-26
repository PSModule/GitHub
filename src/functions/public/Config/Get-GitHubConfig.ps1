#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '6.0.0' }

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
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Initialize-GitHubConfig
    }

    process {
        try {
            if (-not $Name) {
                return [GitHubConfig]($script:GitHub.Config)
            }

            $script:GitHub.Config.$Name
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
