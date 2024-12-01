filter ConvertFrom-GitHubOutput {
    <#
        .SYNOPSIS
        Gets the GitHub output.

        .DESCRIPTION
        Gets the GitHub output from $env:GITHUB_OUTPUT and creates an object with key-value pairs,
        supporting both single-line and multi-line values, and parsing JSON values.

        .EXAMPLE
        $content = @'
        zen=something else
        result={"MyOutput":"Hello, World!","Status":"Success"}
        MY_VALUE<<EOF_12a089b9-051e-4c4e-91c9-8e24fc2fbbf6
        Line1
        Line2
        Line3
        EOF_12a089b9-051e-4c4e-91c9-8e24fc2fbbf6
        Config={"Nested":{"SubSetting":"SubValue"},"Setting1":"Value1","Setting2":2}
        Numbers=12345
        '@

        $content | ConvertFrom-GitHubOutput

        zen      : something else
        result   : @{MyOutput=Hello, World!; Status=Success}
        MY_VALUE : Line1
                Line2
                Line3
        Config   : {[Nested, System.Collections.Hashtable], [Setting1, Value1], [Setting2, 2]}
        Numbers  : 12345

        This will convert the GitHub Actions output syntax to a PowerShell object.

    #>
    [OutputType([object])]
    [CmdletBinding()]
    param(
        # The input data to convert
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [string[]] $InputData
    )

    begin {
        $lines = @()
    }

    process {
        foreach ($item in $InputData) {
            if ($item -is [string]) {
                $lines += $item -split "`n"
            }
        }
    }

    end {
        # Initialize variables
        $result = @{}
        $i = 0

        while ($i -lt $lines.Count) {
            $line = $lines[$i].Trim()

            # Skip empty lines or delimiter lines
            if ($line -match '^-+$' -or [string]::IsNullOrWhiteSpace($line)) {
                $i++
                continue
            }

            # Check for key=value pattern
            if ($line -match '^([^=]+)=(.*)$') {
                $key = $Matches[1].Trim()
                $value = $Matches[2]

                # Attempt to parse JSON
                if (Test-Json $value -ErrorAction SilentlyContinue) {
                    $value = ConvertFrom-Json $value
                }

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

                while ($i -lt $lines.Count -and $lines[$i] -ne $eof_marker) {
                    $value_lines += $lines[$i]
                    $i++
                }

                # Skip the EOF marker
                if ($i -lt $lines.Count -and $lines[$i] -eq $eof_marker) {
                    $i++
                }

                $value = $value_lines -join "`n"

                if (Test-Json $value -ErrorAction SilentlyContinue) {
                    $value = ConvertFrom-Json $value
                }

                $result[$key] = $value
                continue
            }
            $i++
        }
        return [PSCustomObject]$result
    }
}
