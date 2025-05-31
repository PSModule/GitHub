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

        .EXAMPLE
        Write-GitHubLog -Message 'Working...' -NoNewLine
        Write-GitHubLog -Message ' Done!'

        Writes 'Working... Done!' on the same line.

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
        [Parameter(Mandatory, Position = 0)]
        [string] $Message,

        # Foreground color for the message
        [Parameter()]
        [System.ConsoleColor] $ForegroundColor,

        # Background color for the message
        [Parameter()]
        [System.ConsoleColor] $BackgroundColor,

        # Output the message without a trailing newline
        [Parameter()]
        [switch] $NoNewLine
    )

    begin {
        # $stackPath = Get-PSCallStackPath
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
            Write-Host $($outputMessage | Out-String) -NoNewline:$NoNewLine
            return
        }
        Write-Host $Message -NoNewline:$NoNewLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
