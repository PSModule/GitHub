function Get-GitHubOutput {
    <#
        .SYNOPSIS
        Gets the GitHub output.

        .DESCRIPTION
        Gets the GitHub output from $env:GITHUB_OUTPUT and creates an object with key-value pairs, supporting both single-line and multi-line values

        .EXAMPLE
        Get-GitHubOutput
        MY_VALUE         result                       zen
        --------         ------                       ---
        qwe…             {"MyOutput":"Hello, World!"} something else

        Gets the GitHub output and returns an object with key-value pairs.
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param()

    # Initialize variables
    $result = @{}
    $i = 0

    while ($i -lt $InputData.Count) {
        $line = $InputData[$i].Trim()

        # Skip empty lines or delimiter lines
        if ($line -match '^-+$' -or [string]::IsNullOrWhiteSpace($line)) {
            $i++
            continue
        }

        # Check for key=value pattern
        if ($line -match '^([^=]+)=(.*)$') {
            $key = $Matches[1].Trim()
            $value = $Matches[2]
            $result[$key] = $value
            $i++
            continue
        }

        # Check for key<<EOF pattern
        if ($line -match '^([^<]+)<<(\w+)$') {
            $key = $Matches[1].Trim()
            $eof_marker = $Matches[2]
            $i++
            $value_lines = @()

            while ($i -lt $InputData.Count -and $InputData[$i] -ne $eof_marker) {
                $value_lines += $InputData[$i]
                $i++
            }

            # Skip the EOF marker
            if ($i -lt $InputData.Count -and $InputData[$i] -eq $eof_marker) {
                $i++
            }

            $value = $value_lines -join "`n"
            if (Test-Json $value) {
                $value = ConvertFrom-Json $value
            }
            $result[$key] = $value
            continue
        }

        # If line doesn't match any pattern, move to the next line
        $i++
    }

    # Convert the result to a PowerShell object
    return [PSCustomObject]$result
}
