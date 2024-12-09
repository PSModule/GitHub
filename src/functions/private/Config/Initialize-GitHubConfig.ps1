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
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
    }

    process {
        Write-Verbose "GitHubConfig ID: [$($script:GitHub.Config.ID)]"
        Write-Verbose "Force:           [$Force]"
        if (-not $script:GitHub.Config.ID -or $Force) {
            try {
                Write-Verbose 'Attempt to load the stored GitHubConfig from ContextVault'
                $context = [GitHubConfig](Get-Context -ID $script:GitHub.Config.ID)
                if (-not $context -or $Force) {
                    Write-Verbose 'No stored config found. Loading GitHubConfig from defaults'
                    $context = Set-Context -ID $script:GitHub.DefaultConfig.ID -Context $script:GitHub.DefaultConfig -PassThru
                }
                Write-Verbose 'GitHubConfig loaded into memory.'
                $script:GitHub.Config = [GitHubConfig]$context
            } catch {
                Write-Error $_
                throw 'Failed to initialize GitHub config'
            }
        } else {
            Write-Verbose 'GitHubConfig already initialized and available in memory.'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
