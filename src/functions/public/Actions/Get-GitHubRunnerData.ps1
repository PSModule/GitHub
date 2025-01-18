function Get-GitHubRunnerData {
    <#
        .SYNOPSIS
        Get data of the runner thats running the workflow.

        .DESCRIPTION
        Get data of the runner thats running the workflow.

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

