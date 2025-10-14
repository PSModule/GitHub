function Get-GitHubEventData {
    <#
        .SYNOPSIS
        Gets data about the event that triggered the workflow.

        .DESCRIPTION
        Gets data about the event that triggered the workflow.

        .EXAMPLE
        ```powershell
        Get-GitHubEventData
        ```

        .LINK
        https://psmodule.io/GitHub/Functions/Actions/Data/Get-GitHubEventData
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
