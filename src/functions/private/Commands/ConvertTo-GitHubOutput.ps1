filter ConvertTo-GitHubOutput {
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
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
    }

    process {
        try {
            $outputLines = @()

            if ($InputObject -is [hashtable]) {
                $InputObject = [PSCustomObject]$InputObject
            }

            foreach ($property in $InputObject.PSObject.Properties) {
                $key = $property.Name
                $value = $property.Value

                # Convert hashtable or PSCustomObject to compressed JSON
                if ($value -is [hashtable] -or $value -is [PSCustomObject]) {
                    $value = $value | ConvertTo-Json -Compress
                }

                if ($value -is [string] -and $value.Contains("`n")) {
                    # Multi-line value
                    $guid = [Guid]::NewGuid().ToString()
                    $EOFMarker = "EOF_$guid"
                    $outputLines += "$key<<$EOFMarker"
                    $outputLines += $value
                    $outputLines += $EOFMarker
                } else {
                    # Single-line value
                    $outputLines += "$key=$value"
                }
            }
            $outputLines
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
