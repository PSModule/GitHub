function Get-GitHubConfig {
    <#
        .SYNOPSIS
        Get a GitHub module configuration.

        .DESCRIPTION
        Get a GitHub module configuration.

        .EXAMPLE
        Get-GitHubConfig -Name DefaultContext

        Get the DefaultContext value from the GitHub module configuration.

        .LINK
        https://psmodule.io/GitHub/Functions/Config/Get-GitHubConfig
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
        if (-not $Name) {
            return [GitHubConfig]($script:GitHub.Config)
        }

        $script:GitHub.Config.$Name
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
