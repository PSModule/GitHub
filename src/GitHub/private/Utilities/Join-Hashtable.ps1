function Join-Hashtable {
    [OutputType([void])]
    [Alias('Merge-HashTable')]
    [CmdletBinding()]
    param (
        [hashtable] $Main,
        [hashtable] $Overrides
    )
    $Overrides.Keys | ForEach-Object {
        $Main.$_ = $Overrides.$_
    }
}
