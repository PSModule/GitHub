function Get-GitHubGitConfig {
    <#
        .SYNOPSIS
        Gets the global Git configuration.

        .DESCRIPTION
        Gets the global Git configuration.

        .EXAMPLE
        Get-GitHubGitConfig

        Gets the global Git configuration.
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param()

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    $gitExists = Get-Command -Name 'git' -ErrorAction SilentlyContinue
    if (-not $gitExists) {
        throw 'Git is not installed. Please install Git before running this command.'
    }

    git config --global --list | ForEach-Object {
        (
            [pscustomobject]@{
                Name  = $_.Split('=')[0]
                Value = $_.Split('=')[1]
            }
        )
    }

    Write-Verbose "[$commandName] - End"
}
