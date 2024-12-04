function Write-GitHubError {
    <#
        .SYNOPSIS
        Write a error message in GitHub Actions

        .DESCRIPTION
        Write a error message in GitHub Actions. The message will be displayed in the GitHub Actions log.

        .EXAMPLE
        Write-GitHubError -Message 'Hello, World!'

        Writes a error message 'Hello, World!'.

        .NOTES
        [Enabling debug logging](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#setting-an-error-message)
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
    [Alias('Error')]
    [CmdletBinding()]
    param(
        # Message to write
        [Parameter(Mandatory)]
        [string] $Message,

        # The name of the file that this error is related to
        [Parameter()]
        [string] $Name,

        # The line number that this error is related to
        [Parameter()]
        [int] $Line,

        # The column number that this error is related to
        [Parameter()]
        [int] $Column,

        # The end column number that this error is related to
        [Parameter()]
        [int] $EndColumn,

        # The end line number that this error is related to
        [Parameter()]
        [int] $EndLine,

        # The title of the error
        [Parameter()]
        [string] $Title
    )

    if ($env:GITHUB_ACTIONS -eq 'true') {
        Write-Host "::error file=$Name,line=$Line,col=$Column,endColumn=$EndColumn,endLine=$EndLine,title=$Title::$Message"
    } else {
        Write-Error $Message
    }
}
