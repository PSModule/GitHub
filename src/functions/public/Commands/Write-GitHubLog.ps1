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
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Message,
        
        # Foreground color for the message
        [Parameter()]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $PSStyle.Foreground.PSObject.Properties.Name | Where-Object { $_ -like "$wordToComplete*" }
        })]
        [string] $ForegroundColor,
        
        # Background color for the message
        [Parameter()]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $PSStyle.Background.PSObject.Properties.Name | Where-Object { $_ -like "$wordToComplete*" }
        })]
        [string] $BackgroundColor,
        
        # Output the message without a trailing newline
        [Parameter()]
        [switch] $NoNewLine
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        # If not running on GitHub Actions, just output normally
        if ($env:GITHUB_ACTIONS -ne 'true') {
            $params = @{
                Object = $Message
            }
            
            if ($NoNewLine) {
                $params['NoNewLine'] = $true
            }
            
            Write-Host @params
            return
        }
        
        # Running in GitHub Actions, so use ANSI colors
        # Build the ANSI escape sequence string using $PSStyle values
        $ansiString = ""
        if ($ForegroundColor) {
            $ansiString += $PSStyle.Foreground.$ForegroundColor
        }
        if ($BackgroundColor) {
            $ansiString += $PSStyle.Background.$BackgroundColor
        }
        $ansiReset = $PSStyle.Reset

        # Format the output message with ANSI colors
        $outputMessage = "$ansiString$Message$ansiReset"

        # Write the message with or without a newline
        if ($NoNewLine) {
            Write-Host -NoNewline $outputMessage
        } else {
            Write-Host $outputMessage
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}