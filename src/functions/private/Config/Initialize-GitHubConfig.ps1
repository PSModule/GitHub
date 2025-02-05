#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '6.0.0' }

function Initialize-GitHubConfig {
    <#
        .SYNOPSIS
        Initialize the GitHub module configuration.

        .DESCRIPTION
        Initialize the GitHub module configuration.

        .EXAMPLE
        Initialize-GitHubConfig

        Initializes the GitHub module configuration.

        .EXAMPLE
        Initialize-GitHubConfig -Force

        Forces the initialization of the GitHub module configuration.
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param (
        # Force the initialization of the GitHub config.
        [switch] $Force
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        Write-Debug "Force:           [$Force]"
        if ($Force) {
            Write-Debug 'Forcing initialization of GitHubConfig.'
            $context = Set-Context -ID $script:GitHub.DefaultConfig.ID -Context $script:GitHub.DefaultConfig -PassThru
            $script:GitHub.Config = [GitHubConfig]$context
            return
        }

        Write-Debug "GitHubConfig ID: [$($script:GitHub.Config.ID)]"
        if ($null -ne $script:GitHub.Config) {
            Write-Debug 'GitHubConfig already initialized and available in memory.'
            return
        }

        Write-Debug 'Attempt to load the stored GitHubConfig from ContextVault'
        $context = Get-Context -ID $script:GitHub.DefaultConfig.ID
        if ($context) {
            Write-Debug 'GitHubConfig loaded into memory.'
            $script:GitHub.Config = [GitHubConfig]$context
            return
        }
        Write-Debug 'Initializing GitHubConfig from defaults'
        $context = Set-Context -ID $script:GitHub.DefaultConfig.ID -Context $script:GitHub.DefaultConfig -PassThru
        $script:GitHub.Config = [GitHubConfig]$context
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
