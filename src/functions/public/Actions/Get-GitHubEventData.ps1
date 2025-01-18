function Get-GitHubEventData {
    <#
        .SYNOPSIS
        Get data of the event that triggered the workflow.

        .DESCRIPTION
        Get data of the event that triggered the workflow.

        .EXAMPLE
        Get-GitHubEventData
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param()

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $script:GitHub.Event
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

