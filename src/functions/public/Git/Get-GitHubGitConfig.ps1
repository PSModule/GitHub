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
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        try {

            $gitExists = Get-Command -Name 'git' -ErrorAction SilentlyContinue
            if (-not $gitExists) {
                Write-Warning "Git is not installed. Cannot configure Git."
                return
            }

            $null = git rev-parse --is-inside-work-tree 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Warning 'Not a Git repository. Cannot configure Git.'
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
        Write-Debug "[$stackPath] - End"
    }
}
