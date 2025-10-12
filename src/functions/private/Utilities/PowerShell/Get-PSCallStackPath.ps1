function Get-PSCallStackPath {
    <#
        .SYNOPSIS
        Create a string representation of the current call stack.

        .DESCRIPTION
        This function creates a string representation of the current call stack.
        You can use the SkipFirst and SkipLatest parameters to skip the first and last.
        By default it will skip the first (what called the initial function, typically <ScriptBlock>),
        and the last (the current function, Get-PSCallStackPath).

        .EXAMPLE
        ```pwsh
        Get-PSCallStackPath
        First-Function\Second-Function\Third-Function
        ```

        Shows the call stack of the last function called, Third-Function, with the first (<ScriptBlock>)
        and last (Get-PSCallStackPath) functions removed.

        .EXAMPLE
        ```pwsh
        Get-PSCallStackPath -SkipFirst 0
        <ScriptBlock>\First-Function\Second-Function\Third-Function
        ```

        Shows the call stack of the last function called, Third-Function, with the first function included (typically <ScriptBlock>).

        .EXAMPLE
        ```pwsh
        Get-PSCallStackPath -SkipLatest 0
        First-Function\Second-Function\Third-Function\Get-PSCallStackPath
        ```

        Shows the call stack of the last function called, Third-Function, with the last function included (Get-PSCallStackPath).
    #>
    [CmdletBinding()]
    param(
        # Number of the functions to skip from the last function called.
        # Last function is this function, Get-PSCallStackPath.
        [Parameter()]
        [int] $SkipLatest = 1,

        # Number of the functions to skip from the first function called.
        # First function is typically <ScriptBlock>.
        [Parameter()]
        [int] $SkipFirst = 1
    )
    $skipFirst++
    $cmds = (Get-PSCallStack).Command
    $functionPath = $cmds[($cmds.Count - $skipFirst)..$SkipLatest] -join '\'
    $functionPath = $functionPath -replace '^.*<ScriptBlock>\\'
    $functionPath = $functionPath -replace '^.*.ps1\\'
    return $functionPath
}
