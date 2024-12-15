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

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $Context = Resolve-GitHubContext -Context $Context
    }

    process {
        try {

            $gitExists = Get-Command -Name 'git' -ErrorAction SilentlyContinue
            if (-not $gitExists) {
                throw 'Git is not installed. Please install Git before running this command.'
            }

            git config --local --list | ForEach-Object {
                (
                    [pscustomobject]@{
                        Name  = $_.Split('=')[0]
                        Value = $_.Split('=')[1]
                    }
                )
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
