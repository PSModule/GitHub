﻿function Get-GitHubGitConfig {
    <#
        .SYNOPSIS
        Gets the global Git configuration.

        .DESCRIPTION
        Gets the global Git configuration.

        .EXAMPLE
        Get-GitHubGitConfig

        Gets the global Git configuration.
    #>
    [OutputType([object[]])]
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('local', 'global', 'system')]
        [string] $Scope = 'local'
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        try {
            $gitExists = Get-Command -Name 'git' -ErrorAction SilentlyContinue
            Write-Debug "GITEXISTS: $gitExists"
            if (-not $gitExists) {
                Write-Verbose 'Git is not installed. Cannot get git configuration.'
                return
            }

            $cmdresult = git rev-parse --is-inside-work-tree 2>&1
            Write-Debug "LASTEXITCODE: $LASTEXITCODE"
            Write-Debug "CMDRESULT:    $cmdresult"
            if ($LASTEXITCODE -ne 0) {
                Write-Verbose 'Not a git repository. Cannot get git configuration.'
                $Global:LASTEXITCODE = 0
                Write-Debug "Resetting LASTEXITCODE: $LASTEXITCODE"
                return
            }

            $config = @()
            $configList = git config --$Scope --list 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Verbose "Failed to get git configuration for [$Scope]."
                $global:LASTEXITCODE = 0
                Write-Debug "Resetting LASTEXITCODE: $LASTEXITCODE"
                return $config
            }

            $configList = $configList | Sort-Object
            $configList | ForEach-Object {
                $name, $value = $_ -split '=', 2
                $config += @{
                    ($name.Trim()) = ($value.Trim())
                }
            }
            $config
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
