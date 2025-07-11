﻿filter ConvertTo-GitHubOutput {
    <#
    .SYNOPSIS
        Converts a PowerShell object's properties to expected format for GitHub Actions output syntax.

    .DESCRIPTION
        The function iterates over each property of the provided PowerShell object and writes
        them to a specified file in the format used by GitHub Actions for outputs. It supports:
        - Single-line values (written as key=value).
        - Multi-line string values (using key<<EOF syntax with a unique EOF marker).
        - Converts hashtables and PSCustomObject values to compressed JSON strings.

    .EXAMPLE
        $object = [PSCustomObject]@{
            zen      = 'something else'
            result   = [PSCustomObject]@{ MyOutput = "Hello, World!"; Status = "Success" }
            MY_VALUE = "Line1`nLine2`nLine3"
            Config   = @{ Setting1 = "Value1"; Setting2 = 2; Nested = @{ SubSetting = "SubValue" } }
            Numbers  = 12345
        }

        $object | ConvertTo-GitHubOutput

        zen=something else
        result={"MyOutput":"Hello, World!","Status":"Success"}
        MY_VALUE<<EOF_12a089b9-051e-4c4e-91c9-8e24fc2fbbf6
        Line1
        Line2
        Line3
        EOF_12a089b9-051e-4c4e-91c9-8e24fc2fbbf6
        Config={"Nested":{"SubSetting":"SubValue"},"Setting1":"Value1","Setting2":2}
        Numbers=12345

        This will convert the properties of $object to GitHub Actions output syntax.

    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The PowerShell object containing the key-value pairs to be saved.
        # Each property of the object represents a key.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [object] $InputObject
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $outputLines = @()

        Write-Debug "Input object type: $($InputObject.GetType().Name)"
        Write-Debug 'Input object value:'
        Write-Debug ($InputObject | Out-String)

        if ($InputObject -is [hashtable]) {
            $InputObject = [PSCustomObject]$InputObject
        }
        foreach ($property in $InputObject.PSObject.Properties) {
            $key = $property.Name
            $value = $property.Value

            Write-Debug "Processing property: $key"
            Write-Debug "Property value type: $($null -eq $value ? 'null' : $value.GetType().Name)"
            Write-Debug 'Property value:'
            Write-Debug ($InputObject | Out-String)

            $guid = [Guid]::NewGuid().ToString()
            $EOFMarker = "EOF_$guid"
            $outputLines += "$key<<$EOFMarker"

            # Handle null values - leave a blank line between delimiters for empty string
            # and no blank line for null
            if ($null -eq $value) {
                Write-Debug "Null value for key: $key"
                # No output between delimiters for null
            } elseif ($value -is [string] -and $value -eq '') {
                Write-Debug "Empty string value for key: $key"
                # Add a blank line for empty string
                $outputLines += ''
            } else {
                # For each non-null, non-empty property value:
                if ($value -is [string]) {
                    if (Test-Json $value -ErrorAction SilentlyContinue) {
                        # Normalize valid JSON strings to a consistent format.
                        $value = ($value | ConvertFrom-Json) | ConvertTo-Json -Depth 100 -Compress
                    }
                } else {
                    # For non-string values, convert to JSON.
                    # Special handling for properties that may contain null values
                    try {
                        $value = $value | ConvertTo-Json -Depth 100 -Compress
                    } catch {
                        Write-Debug "Error converting value to JSON: $_"
                        $value = if ($null -eq $value) { 'null' } else { $value.ToString() }
                    }
                }
                $outputLines += $value
            }

            $outputLines += $EOFMarker
        }
        Write-Debug 'Output lines:'
        Write-Debug ($outputLines | Out-String)
        $outputLines
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
