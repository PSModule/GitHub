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
    [OutputType([pscustomobject])]
    [OutputType([hashtable])]
    [CmdletBinding()]
    param(
        # The input data to convert
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [AllowNull()]
        [string[]] $InputData,

        # Whether to convert the input data to a hashtable
        [switch] $AsHashtable
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $lines = @()
    }

    process {
        Write-Debug "[$stackPath] - Process - Start"
        if (-not $InputData) {
            $InputData = ''
        }
        foreach ($line in $InputData) {
            Write-Debug "Line: $line"
            $lines += $line -split "`n"
        }
        Write-Debug "[$stackPath] - Process - End"
    }

    end {
        Write-Debug "[$stackPath] - End - Start"
        # Initialize variables
        $result = @{}
        $i = 0

        Write-Debug "Lines: $($lines.Count)"
        $lines | ForEach-Object { Write-Debug "[$_]" }

        while ($i -lt $lines.Count) {
            $line = $lines[$i].Trim()
            Write-Debug "[$line]"

            # Check for key=value pattern
            if ($line -match '^([^=]+)=(.*)$') {
                Write-Debug " - key=value pattern"
                $key = $Matches[1].Trim()
                $value = $Matches[2]

                if ([string]::IsNullOrWhiteSpace($value) -or [string]::IsNullOrEmpty($value)) {
                    $result[$key] = ''
                    $i++
                    continue
                }

                # Attempt to parse JSON
                if (Test-Json $value -ErrorAction SilentlyContinue) {
                    Write-Debug "[$key] - value is JSON"
                    $value = ConvertFrom-Json $value -AsHashtable:$AsHashtable
                }

                $result[$key] = $value
                $i++
                continue
            }

            # Check for key<<EOF pattern
            if ($line -match '^([^<]+)<<(\S+)$') {
                Write-Debug ' - key<<EOF pattern'
                $key = $Matches[1].Trim()
                $eof_marker = $Matches[2]
                Write-Debug " - key<<EOF pattern - [$eof_marker] - Start"
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
                    Write-Debug " - key<<EOF pattern - [$eof_marker] - End"
                    $i++
                }

                $value = $value_lines -join "`n"

                if ([string]::IsNullOrWhiteSpace($value) -or [string]::IsNullOrEmpty($value)) {
                    $result[$key] = ''
                    continue
                }

                if (Test-Json $value -ErrorAction SilentlyContinue) {
                    Write-Debug ' - key<<EOF pattern - value is JSON'
                    $value = ConvertFrom-Json $value -AsHashtable:$AsHashtable
                }

                $result[$key] = $value
                continue
            }

            # Unexpected line type
            Write-Debug ' - Skipping empty line'
            $i++
            continue
        }
        if ($AsHashtable) {
            $result
        } else {
            [PSCustomObject]$result
        }
        Write-Debug "[$stackPath] - End - End"
    }
}
