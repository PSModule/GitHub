function Join-Hashtable {
    [OutputType([void])]
    [Alias('Merge-HashTable')]
    [CmdletBinding()]
    param (
        [hashtable] $Main,
        [hashtable] $Overrides
    )
    $hashtable = @{}
    $Main.Keys | ForEach-Object {
        $hashtable[$_] = $Main[$_]
    }
    $Overrides.Keys | ForEach-Object {
        $hashtable[$_] = $Overrides[$_]
    }
    $hashtable
}

$object = [pscustomobject]@{
    'a' = '1'
    'b' = '1'
}

$hashtable = @{
    'b' = '2'
    'c' = '2'
}

Join-HashTable -Main $object -Overrides $hashtable
