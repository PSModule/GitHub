function Get-GitHubCompletionPattern {
    <#
        .SYNOPSIS
        Get the completion pattern based on the current GitHub configuration.

        .DESCRIPTION
        Get the completion pattern based on the current GitHub configuration CompletionMode setting.
        Returns either a 'StartsWith' pattern ($wordToComplete*) or 'Contains' pattern (*$wordToComplete*).

        .EXAMPLE
        Get-GitHubCompletionPattern -WordToComplete 'test'

        Returns 'test*' when CompletionMode is 'StartsWith', or '*test*' when CompletionMode is 'Contains'.

        .OUTPUTS
        string
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # The word being completed
        [Parameter(Mandatory)]
        [string] $WordToComplete
    )
    $completionMode = $script:GitHub.Config.CompletionMode
    Write-Debug "CompletionMode: [$completionMode]"

    $pattern = switch ($completionMode) {
        'Contains' { "*$WordToComplete*" }
        default { "$WordToComplete*" }
    }

    Write-Debug "Pattern: [$pattern]"
    $pattern
}
