function Write-GitHubLog {
    <#
        .SYNOPSIS
        Write a colored message in GitHub Actions or locally

        .DESCRIPTION
        Write a colored message in GitHub Actions or locally with ANSI color support.
        When running in GitHub Actions, uses ANSI color codes for text formatting.
        When not running in GitHub Actions, uses standard Write-Host.

        .EXAMPLE
        Write-GitHubLog -Message 'Hello, World!'

        Writes 'Hello, World!' to the log.

        .EXAMPLE
        Write-GitHubLog -Message 'Error occurred!' -ForegroundColor Red

        Writes 'Error occurred!' in red text.

        .EXAMPLE
        Write-GitHubLog -Message 'Success!' -ForegroundColor Green -BackgroundColor Black

        Writes 'Success!' in green text on a black background.

        .NOTES
        Uses PowerShell's $PSStyle for ANSI color rendering when supported.

        .LINK
        https://psmodule.io/GitHub/Functions/Commands/Write-GitHubLog
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '', Scope = 'Function',
        Justification = 'Intended for logging in Github Runners'
    )]
    [OutputType([void])]
    [Alias('Log')]
    [CmdletBinding()]
    param(
        # The message to display
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string] $Message,

        # Foreground color for the message
        [Parameter()]
        [System.ConsoleColor] $ForegroundColor,

        # Background color for the message
        [Parameter()]
        [System.ConsoleColor] $BackgroundColor
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        if ($env:GITHUB_ACTIONS -eq 'true') {
            $ansiString = ''
            if ($ForegroundColor) {
                $ansiString += $PSStyle.Foreground.$ForegroundColor
            }
            if ($BackgroundColor) {
                $ansiString += $PSStyle.Background.$BackgroundColor
            }
            $ansiReset = $PSStyle.Reset
            $outputMessage = "$ansiString$Message$ansiReset"
            Write-Host $($outputMessage | Out-String)
            return
        }
        Write-Host $Message -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
