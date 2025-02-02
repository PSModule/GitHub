function ConvertTo-GitHubCodespace {
    [OutputType([GitHubCodespace])]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
    process {
        [GitHubCodespace]$InputObject
    }
}
