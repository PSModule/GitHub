function Get-GitHubStamp {
    <#
        .SYNOPSIS
        Gets the available GitHub Status page stamps (regions).

        .DESCRIPTION
        Returns the available GitHub Status page stamps, which represent different regional status pages.
        Each stamp includes the name and base URL of the status page.

        .EXAMPLE
        ```powershell
        Get-GitHubStamp
        ```

        Gets all available GitHub Status page stamps.

        .EXAMPLE
        ```powershell
        Get-GitHubStamp -Name 'Europe'
        ```

        Gets the GitHub Status page stamp for 'Europe'.

        .NOTES
        [GitHub Status API](https://www.githubstatus.com/api)

        .LINK
        https://psmodule.io/GitHub/Functions/Status/Get-GitHubStamp
    #>
    [OutputType([GitHubStamp[]])]
    [CmdletBinding()]
    param(
        # The name of the stamp to get. If not specified, all stamps are returned.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('Stamp')]
        [string] $Name
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        if ([string]::IsNullOrEmpty($Name)) {
            $script:GitHub.Stamps
            return
        }

        $stamp = $script:GitHub.Stamps | Where-Object { $_.Name -eq $Name }
        if (-not $stamp) {
            $available = $script:GitHub.Stamps.Name -join ', '
            throw "Stamp '$Name' not found. Available stamps: $available"
        }
        $stamp
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
