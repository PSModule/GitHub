filter Remove-HashtableEntry {
    <#
        .SYNOPSIS
        Remove entries from a hashtable.

        .DESCRIPTION
        Remove different types of entries from a hashtable.

        .EXAMPLE
        $Hashtable = @{
            'Key1' = 'Value1'
            'Key2' = 'Value2'
            'Key3' = $null
            'Key4' = 'Value4'
            'Key5' = ''
        }
        $Hashtable | Remove-HashtableEntry -NullOrEmptyValues

        Remove keys with null or empty values
    #>
    [OutputType([void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Function does not change state.'
    )]
    [CmdletBinding()]
    param(
        # The hashtable to remove entries from.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [hashtable] $Hashtable,

        # Remove keys with null or empty values.
        [Parameter()]
        [switch] $NullOrEmptyValues,

        # Remove keys of type.
        [Parameter()]
        [string[]] $RemoveTypes,

        # Remove keys with a given name.
        [Parameter()]
        [string[]] $RemoveNames,

        # Remove keys NOT of type.
        [Parameter()]
        [string[]] $KeepTypes,

        # Remove keys NOT with a given name.
        [Parameter()]
        [string[]] $KeepNames
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        try {
            if ($NullOrEmptyValues) {
                Write-Debug 'Remove keys with null or empty values'
            ($Hashtable.GetEnumerator() | Where-Object { [string]::IsNullOrEmpty($_.Value) }) | ForEach-Object {
                    Write-Debug " - [$($_.Name)] - Value: [$($_.Value)] - Remove"
                    $Hashtable.Remove($_.Name)
                }
            }
            if ($RemoveTypes) {
                Write-Debug "Remove keys of type: [$RemoveTypes]"
            ($Hashtable.GetEnumerator() | Where-Object { ($_.Value.GetType().Name -in $RemoveTypes) }) | ForEach-Object {
                    Write-Debug " - [$($_.Name)] - Type: [$($_.Value.GetType().Name)] - Remove"
                    $Hashtable.Remove($_.Name)
                }
            }
            if ($KeepTypes) {
                Write-Debug "Remove keys NOT of type: [$KeepTypes]"
            ($Hashtable.GetEnumerator() | Where-Object { ($_.Value.GetType().Name -notin $KeepTypes) }) | ForEach-Object {
                    Write-Debug " - [$($_.Name)] - Type: [$($_.Value.GetType().Name)] - Remove"
                    $Hashtable.Remove($_.Name)
                }
            }
            if ($RemoveNames) {
                Write-Debug "Remove keys named: [$RemoveNames]"
            ($Hashtable.GetEnumerator() | Where-Object { $_.Name -in $RemoveNames }) | ForEach-Object {
                    Write-Debug " - [$($_.Name)] - Remove"
                    $Hashtable.Remove($_.Name)
                }
            }
            if ($KeepNames) {
                Write-Debug "Remove keys NOT named: [$KeepNames]"
            ($Hashtable.GetEnumerator() | Where-Object { $_.Name -notin $KeepNames }) | ForEach-Object {
                    Write-Debug " - [$($_.Name)] - Remove"
                    $Hashtable.Remove($_.Name)
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
