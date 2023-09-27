function Remove-HashtableEntries {
    [OutputType([void])]
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [hashtable] $Hashtable,
        [Parameter()]
        [switch] $NullOrEmptyValues,
        [Parameter()]
        [string[]] $RemoveTypes,
        [Parameter()]
        [string[]] $RemoveNames,
        [Parameter()]
        [string[]] $KeepTypes,
        [Parameter()]
        [string[]] $KeepNames

    )
    if ($NullOrEmptyValues) {
        Write-Verbose 'Remove keys with null or empty values'
        ($Hashtable.GetEnumerator() | Where-Object { -not $_.Value }) | ForEach-Object {
            Write-Verbose " - [$($_.Name)] - Value: [$($_.Value)] - Remove"
            $Hashtable.Remove($_.Name)
        }
    }
    if ($RemoveTypes) {
        Write-Verbose "Remove keys of type: [$RemoveTypes]"
        ($Hashtable.GetEnumerator() | Where-Object { ($_.Value.GetType().Name -in $RemoveTypes) }) | ForEach-Object {
            Write-Verbose " - [$($_.Name)] - Type: [$($_.Value.GetType().Name)] - Remove"
            $Hashtable.Remove($_.Name)
        }
    }
    if ($KeepTypes) {
        Write-Verbose "Remove keys NOT of type: [$KeepTypes]"
        ($Hashtable.GetEnumerator() | Where-Object { ($_.Value.GetType().Name -notin $KeepTypes) }) | ForEach-Object {
            Write-Verbose " - [$($_.Name)] - Type: [$($_.Value.GetType().Name)] - Remove"
            $Hashtable.Remove($_.Name)
        }
    }
    if ($RemoveNames) {
        Write-Verbose "Remove keys named: [$RemoveNames]"
        ($Hashtable.GetEnumerator() | Where-Object { $_.Name -in $RemoveNames }) | ForEach-Object {
            Write-Verbose " - [$($_.Name)] - Remove"
            $Hashtable.Remove($_.Name)
        }
    }
    if ($KeepNames) {
        Write-Verbose "Remove keys NOT named: [$KeepNames]"
        ($Hashtable.GetEnumerator() | Where-Object { $_.Name -notin $KeepNames }) | ForEach-Object {
            Write-Verbose " - [$($_.Name)] - Remove"
            $Hashtable.Remove($_.Name)
        }
    }
}
