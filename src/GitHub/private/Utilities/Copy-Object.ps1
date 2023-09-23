function Copy-Object {
    [OutputType([object])]
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
