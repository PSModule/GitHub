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
    [OutputType([GitHubConfig], ParameterSetName = 'Get the module configuration')]
    [OutputType([object], ParameterSetName = 'Get a specific configuration item')]
    [CmdletBinding(DefaultParameterSetName = 'Get the module configuration')]
    param(
        # The name of the configuration to get.
        [Parameter(Mandatory, ParameterSetName = 'Get a specific configuration item')]
        [string] $Name
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Initialize-GitHubConfig
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Get the module configuration' {
                $item = Get-Context -ID $script:GitHub.Config.ID -Vault $script:GitHub.ContextVault | Select-Object -ExcludeProperty ID
                [GitHubConfig]::new($item)
            }
            'Get a specific configuration item' {
                $script:GitHub.Config.$Name
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '8.1.0' }
