function Get-GitHubRunnerData {
    <#
        .SYNOPSIS
        Gets data about the runner thats running the workflow.

        .DESCRIPTION
        Gets data about the runner thats running the workflow.

        .EXAMPLE
        Get-GitHubRunnerData
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param()

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $script:GitHub.Runner
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
