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

        ConvertFrom-GitHubOutput -OutputContent $content

        zen      : something else
        result   : @{MyOutput=Hello, World!; Status=Success}
        MY_VALUE : Line1
                Line2
                Line3
        Config   : {[Nested, System.Collections.Hashtable], [Setting1, Value1], [Setting2, 2]}
        Numbers  : 12345

        This will convert the GitHub Actions output syntax to a PowerShell object.

    #>
    [OutputType([pscustomobject])]
    [OutputType([hashtable])]
    [CmdletBinding()]
    param(
        # The input data to convert
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $OutputContent,

        # Whether to convert the input data to a hashtable
        [switch] $AsHashtable
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        Write-Debug "[$stackPath] - Process - Start"
        $lines = $OutputContent -split [System.Environment]::NewLine
        Write-Debug "[$stackPath] - Output lines: $($lines.Count)"
        if ($lines.count -eq 0) {
            return @{}
        }

        $result = @{}
        $i = 0
        foreach ($line in $lines) {
            Write-Debug "[$line]"

            # Check for key=value pattern (single-line)
            if ($line -match '^([^=]+)=(.*)$') {
                Write-Debug ' - Single-line pattern'
                $key = $Matches[1].Trim()
                $value = $Matches[2]

                Write-Debug " - Single-line pattern - [$key] = [$value]"
                # Check for empty value
                if ([string]::IsNullOrWhiteSpace($value) -or [string]::IsNullOrEmpty($value) -or $value.Length -eq 0) {
                    Write-Debug ' - Single-line pattern - Empty value'
                    $result[$key] = ''
                    $i++
                    continue
                }

                # Attempt to parse JSON
                if (Test-Json $value -ErrorAction SilentlyContinue) {
                    Write-Debug " - Single-line pattern - value is JSON"
                    $value = ConvertFrom-Json $value -AsHashtable:$AsHashtable
                }

                $result[$key] = $value
                $i++
                continue
            }

            # Check for key<<EOF pattern (multi-line)
            if ($line -match '^([^<]+)<<(\S+)$') {
                Write-Debug ' - Multi-line pattern'
                $key = $Matches[1].Trim()
                Write-Debug " - Multi-line pattern' - [$key]"
                $eof_marker = $Matches[2]
                Write-Debug " - Multi-line pattern' - [$key] - [$eof_marker] - Start"
                $i++
                $value_lines = @()

                # Read lines until the EOF marker
                while ($i -lt $lines.Count -and $lines[$i] -ne $eof_marker) {
                    $valueItem = $lines[$i].Trim()
                    Write-Debug "   [$valueItem]"
                    $value_lines += $valueItem
                    $i++
                }

                # Skip the EOF marker
                if ($i -lt $lines.Count -and $lines[$i] -eq $eof_marker) {
                    Write-Debug " - Multi-line pattern' - [$key] - [$eof_marker] - End"
                    $i++
                }

                $value = $value_lines -join [System.Environment]::NewLine

                # Check for empty value
                if ([string]::IsNullOrWhiteSpace($value) -or [string]::IsNullOrEmpty($value) -or $value.Length -eq 0) {
                    Write-Debug " - key<<EOF pattern - [$key] - Empty value"
                    $result[$key] = ''
                    continue
                }

                # Attempt to parse JSON
                if (Test-Json $value -ErrorAction SilentlyContinue) {
                    Write-Debug " - key<<EOF pattern - [$key] - value is JSON"
                    $value = ConvertFrom-Json $value -AsHashtable:$AsHashtable
                }

                $result[$key] = $value
                continue
            }

            # Unexpected line type
            Write-Debug ' - No pattern match - Skipping line'
            $i++
            continue
        }
        Write-Debug "[$stackPath] - Process - End"
    }

    end {
        Write-Debug "[$stackPath] - End - Start"
        if ($AsHashtable) {
            $result
        } else {
            [PSCustomObject]$result
        }
        Write-Debug "[$stackPath] - End - End"
    }
}
