function Get-GitHubRunnerData {
    <#
        .SYNOPSIS
        Gets data about the runner thats running the workflow.

        .DESCRIPTION
        Gets data about the runner thats running the workflow.

        .EXAMPLE
        ```powershell
        Get-GitHubRunnerData
        ```

        .LINK
        https://psmodule.io/GitHub/Functions/Actions/Data/Get-GitHubRunnerData
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
