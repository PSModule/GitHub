function Get-GitHubCompletionPattern {
    <#
        .SYNOPSIS
        Get the completion pattern based on the current GitHub configuration.

        .DESCRIPTION
        Get the completion pattern based on the current GitHub configuration CompletionMode setting.
        Returns either a 'StartsWith' pattern ($wordToComplete*) or 'Contains' pattern (*$wordToComplete*).

        .PARAMETER WordToComplete
        The word being completed.

        .EXAMPLE
        Get-GitHubCompletionPattern -WordToComplete 'test'

        Returns 'test*' when CompletionMode is 'StartsWith', or '*test*' when CompletionMode is 'Contains'.

        .OUTPUTS
        [string] The pattern to use for completion matching.
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # The word being completed
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $WordToComplete
    )

    begin {
        if (Get-Command -Name 'Get-PSCallStackPath' -ErrorAction SilentlyContinue) {
            $stackPath = Get-PSCallStackPath
            Write-Debug "[$stackPath] - Start"
        }
        if (Get-Command -Name 'Initialize-GitHubConfig' -ErrorAction SilentlyContinue) {
            Initialize-GitHubConfig
        }
    }

    process {
        $completionMode = $script:GitHub.Config.CompletionMode
        if (Get-Command -Name 'Write-Debug' -ErrorAction SilentlyContinue) {
            Write-Debug "CompletionMode: [$completionMode]"
        }

        switch ($completionMode) {
            'Contains' {
                $pattern = "*$WordToComplete*"
            }
            default {
                # Default to 'StartsWith' for backward compatibility
                $pattern = "$WordToComplete*"
            }
        }

        if (Get-Command -Name 'Write-Debug' -ErrorAction SilentlyContinue) {
            Write-Debug "Pattern: [$pattern]"
        }
        return $pattern
    }

    end {
        if (Get-Command -Name 'Get-PSCallStackPath' -ErrorAction SilentlyContinue) {
            $stackPath = Get-PSCallStackPath
            Write-Debug "[$stackPath] - End"
        }
    }
}