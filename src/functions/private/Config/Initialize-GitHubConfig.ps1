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
        Write-Verbose "GitHubConfig initialized: [$($script:GitHub.Initialized)]"
        Write-Verbose "Force:                    [$Force]"
        if (-not $script:GitHub.Initialized -or $Force) {
            try {
                $context = [GitHubConfig](Get-Context -ID $script:GitHub.Config.ID)
                if (-not $context -or $Force) {
                    Write-Verbose "Loading GitHubConfig from defaults"
                    $context = Set-Context -ID $script:GitHub.DefaultConfig.ID -Context $script:GitHub.DefaultConfig -PassThru
                }
                $script:GitHub.Config = [GitHubConfig]$context
                $script:GitHub.Initialized = $true
            } catch {
                Write-Error $_
                throw 'Failed to initialize GitHub config'
            }
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
