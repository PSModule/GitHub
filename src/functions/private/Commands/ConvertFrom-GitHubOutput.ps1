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
        [string[]] $InputData,

        # Whether to convert the input data to a hashtable
        [switch] $AsHashtable
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
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
            Write-Debug "[$line]"

            # Skip empty or delimiter lines
            if ($line -match '^-+$' -or [string]::IsNullOrWhiteSpace($line)) {
                Write-Debug "[$line] - Skipping empty line"
                $i++
                continue
            }

            # Check for key=value pattern
            if ($line -match '^([^=]+)=(.*)$') {
                Write-Debug "[$line] - key=value pattern"
                $key = $Matches[1].Trim()
                $value = $Matches[2]

                # Attempt to parse JSON
                if (Test-Json $value -ErrorAction SilentlyContinue) {
                    Write-Debug "[$line] - value is JSON"
                    $value = ConvertFrom-Json $value -AsHashtable:$AsHashtable
                }

                $result[$key] = $value
                $i++
                continue
            }

            # Check for key<<EOF pattern
            if ($line -match '^([^<]+)<<(\S+)$') {
                Write-Debug "[$line] - key<<EOF pattern"
                $key = $Matches[1].Trim()
                $eof_marker = $Matches[2]
                Write-Debug "[$line] - key<<EOF pattern - [$eof_marker]"
                $i++
                $value_lines = @()

                while ($i -lt $lines.Count -and $lines[$i] -ne $eof_marker) {
                    $valueItem = $lines[$i].Trim()
                    Write-Debug "[$line] - key<<EOF pattern - [$eof_marker] - [$valueItem]"
                    $value_lines += $valueItem
                    $i++
                }

                # Skip the EOF marker
                if ($i -lt $lines.Count -and $lines[$i] -eq $eof_marker) {
                    Write-Debug "[$line] - key<<EOF pattern - Closing"
                    $i++
                }

                $value = $value_lines -join "`n"

                if (Test-Json $value -ErrorAction SilentlyContinue) {
                    Write-Debug "[$line] - key<<EOF pattern - value is JSON"
                    $value = ConvertFrom-Json $value -AsHashtable:$AsHashtable
                }

                $result[$key] = $value
                continue
            }
            $i++
        }
        if ($AsHashtable) {
            $result
        } else {
            [PSCustomObject]$result
        }
        Write-Debug "[$commandName] - End"
    }
}
