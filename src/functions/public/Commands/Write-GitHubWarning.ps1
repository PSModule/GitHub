function Write-GitHubWarning {
    <#
        .SYNOPSIS
        Write a warning message in GitHub Actions

        .DESCRIPTION
        Write a warning message in GitHub Actions. The message will be displayed in the GitHub Actions log.

        .EXAMPLE
        Write-GitHubWarning -Message 'Hello, World!'

        Writes a warning message 'Hello, World!'.

        .NOTES
        [Enabling debug logging](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/troubleshooting-workflows/enabling-debug-logging)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '', Scope = 'Function',
        Justification = 'Long doc links'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '', Scope = 'Function',
        Justification = 'Intended for logging in Github Runners'
    )]
    [OutputType([void])]
    [Alias('Warning')]
    [CmdletBinding()]
    param(
        # Message to write
        [Parameter(Mandatory)]
        [string] $Message,

        # The name of the file that this warning is related to
        [Parameter()]
        [string] $Name,

        # The line number that this warning is related to
        [Parameter()]
        [int] $Line,

        # The column number that this warning is related to
        [Parameter()]
        [int] $Column,

        # The end column number that this warning is related to
        [Parameter()]
        [int] $EndColumn,

        # The end line number that this warning is related to
        [Parameter()]
        [int] $EndLine,

        # The title of the warning
        [Parameter()]
        [string] $Title
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        if ($env:GITHUB_ACTIONS -eq 'true') {
            Write-Host "::warning file=$Name,line=$Line,col=$Column,endColumn=$EndColumn,endLine=$EndLine,title=$Title::$Message"
        } else {
            Write-Warning $Message
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
