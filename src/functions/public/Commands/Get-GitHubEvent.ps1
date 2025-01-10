function Get-GitHubEvent {
    <#
        .SYNOPSIS
        Get the event that triggered the workflow

        .DESCRIPTION
        Get the event that triggered the workflow

        .EXAMPLE
        Get-GitHubEvent
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
            $event = [pscustomobject]@{
                Name = $env:GITHUB_EVENT_NAME
            }
            Write-Output $env:GITHUB_EVENT_NAME
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
