function Copy-Object {
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [Object] $InputObject
    )

    process {
        $InputObject | ConvertTo-Json -Depth 100 | ConvertFrom-Json
    }
}
