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
    param (
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
