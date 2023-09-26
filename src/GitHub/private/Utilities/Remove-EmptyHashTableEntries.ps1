function Remove-EmptyHashTableEntries {
    [OutputType([void])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [hashtable] $Hashtable
    )
    ($Hashtable.GetEnumerator() | Where-Object { -not $_.Value }) | ForEach-Object { $Hashtable.Remove($_.Name) }
}
