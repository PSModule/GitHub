filter ConvertFrom-GitHubOutput {
    <#
        .SYNOPSIS
        Gets the GitHub output.

        .DESCRIPTION
        Gets the GitHub output from $env:GITHUB_OUTPUT and creates an object with key-value pairs,
        supporting both single-line and multi-line values, and parsing JSON values.
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The input data to convert
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
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


$multiLineString = @'
zen=Non-blocking is better than blocking.
result={"MyOutput":"Hello, World!"}
MY_VALUE<<EOF
multi
line
value
EOF
'@ #-split "`n"

$outputs = ConvertFrom-GitHubOutput -InputData $multiLineString
$outputs | Format-List
$outputs.result


$outputs = $multiLineString | ConvertFrom-GitHubOutput
$outputs | Format-List
$outputs.result
