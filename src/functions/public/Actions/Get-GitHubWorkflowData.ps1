function Get-GitHubWorkflowData {
    <#
        .SYNOPSIS
        Get data from the workflow and the event that triggered the workflow

        .DESCRIPTION
        Get data from the workflow and the event that triggered the workflow

        .EXAMPLE
        Get-GitHubWorkflowData
    #>
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

