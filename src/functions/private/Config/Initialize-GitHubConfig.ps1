function Initialize-GitHubConfig {
    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
        Initialize-GitHubConfig
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param ()

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
    }

    process {
        try {
            $context = [GitHubConfig](Get-Context -ID $script:GitHub.Config.ID)
            if (-not $context) {
                $context = Set-Context -ID $script:GitHub.Config.ID -Context $script:GitHub.Config -PassThru
            }
            $script:GitHub.Config = [GitHubConfig]$context
            $script:GitHub.Initialized = $true
        } catch {
            Write-Error $_
            throw 'Failed to initialize GitHub config'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
