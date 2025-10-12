function Reset-GitHubOutput {
    <#
        .SYNOPSIS
        Resets the GitHub output.

        .DESCRIPTION
        Resets the GitHub output by clearing the contents of $env:GITHUB_OUTPUT.

        .EXAMPLE
        ```powershell
        Reset-GitHubOutput
        ```

        Resets the content in the GitHub output file.

        .LINK
        https://psmodule.io/GitHub/Functions/Commands/Reset-GitHubOutput
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The path to the GitHub output file.
        [Parameter()]
        [string] $Path = $env:GITHUB_OUTPUT
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        if (-not $Path) {
            throw 'The path to the GitHub output file is not set. Please set the path to the GitHub output file using the -Path parameter.'
        }
        Write-Debug "[$stackPath] - Output path"
        Write-Debug $Path
        if (-not (Test-Path -Path $Path)) {
            throw "File not found: $Path"
        }

        if ($PSCmdlet.ShouldProcess('GitHub Output' , 'Reset')) {
            '' | Set-Content -Path $Path -Force
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
