function Get-GitHubOutput {
    <#
        .SYNOPSIS
        Gets the GitHub output.

        .DESCRIPTION
        Gets the GitHub output from $env:GITHUB_OUTPUT and creates an object with key-value pairs, supporting both single-line and multi-line values

        .EXAMPLE
        ```powershell
        Get-GitHubOutput
        MY_VALUE         result                       zen
        --------         ------                       ---
        qwe…             @{"MyOutput":"Hello, World!"} something else
        ```

        Gets the GitHub output and returns an object with key-value pairs.

        .EXAMPLE
        ```powershell
        Get-GitHubOutput -AsHashtable
        ```

        Name                           Value
        ----                           -----
        MyArray                        1 2 3
        MyOutput                       Hello, World!
        zen                            something else
        result                         {[thisisatest, a simple value]}
        mystuff                        {[MyOutput, Hello, World!]}
        MY_VALUE                       qwe…

        Gets the GitHub output and returns a hashtable.

        .LINK
        https://psmodule.io/GitHub/Functions/Commands/Get-GitHubOutput
    #>
    [OutputType([hashtable])]
    [CmdletBinding()]
    param(
        # Returns the output as a hashtable.
        [Parameter()]
        [switch] $AsHashtable,

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

        $outputContent = Get-Content -Path $Path -Raw
        ConvertFrom-GitHubOutput -OutputContent $outputContent -AsHashtable:$AsHashtable

    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
