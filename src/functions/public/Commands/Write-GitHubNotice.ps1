function Write-GitHubNotice {
    <#
        .SYNOPSIS
        Write a notice message in GitHub Actions

        .DESCRIPTION
        Write a notice message in GitHub Actions. The message will be displayed in the GitHub Actions log.

        .EXAMPLE
        Write-GitHubNotice -Message 'Hello, World!'

        Writes a notice message 'Hello, World!'.

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
    [Alias('Notice')]
    [CmdletBinding()]
    param(
        # Message to write
        [Parameter(Mandatory)]
        [string] $Message,

        # The name of the file that this notice is related to
        [Parameter()]
        [string] $Name,

        # The line number that this notice is related to
        [Parameter()]
        [int] $Line,

        # The column number that this notice is related to
        [Parameter()]
        [int] $Column,

        # The end column number that this notice is related to
        [Parameter()]
        [int] $EndColumn,

        # The end line number that this notice is related to
        [Parameter()]
        [int] $EndLine,

        # The title of the notice
        [Parameter()]
        [string] $Title
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
    }

    process {
        try {
            if ($env:GITHUB_ACTIONS -eq 'true') {
                Write-Host "::notice file=$Name,line=$Line,col=$Column,endColumn=$EndColumn,endLine=$EndLine,title=$Title::$Message"
            } else {
                Write-Host $Message
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
