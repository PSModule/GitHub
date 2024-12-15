function Show-CallStack {
    <#
        .SYNOPSIS
        Create a string representation of the current call stack.

        .DESCRIPTION
        This function creates a string representation of the current call stack.
        You can use the SkipFirst and SkipLatest parameters to skip the first and last.
        By default it will skip the first (what called the initial function, typically <ScriptBlock>),
        and the last (the current function, Show-CallStack).

        .EXAMPLE
        Show-CallStack
        First-Function\Second-Function\Third-Function

        Shows the call stack of the last function called, Third-Function, with the first (<ScriptBlock>) and last (Show-CallStack) functions removed.

        .EXAMPLE
        Show-CallStack -SkipFirst 0
        <ScriptBlock>\First-Function\Second-Function\Third-Function

        Shows the call stack of the last function called, Third-Function, with the first function included (typically <ScriptBlock>).

        .EXAMPLE
        Show-CallStack -SkipLatest 0
        First-Function\Second-Function\Third-Function\Show-CallStack

        Shows the call stack of the last function called, Third-Function, with the last function included (Show-CallStack).
    #>
    [CmdletBinding()]
    param(
        # Number of the functions to skip from the last function called.
        # Last function is this function, Show-CallStack.
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
    return $functionPath
}
