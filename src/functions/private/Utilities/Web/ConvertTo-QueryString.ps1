filter ConvertTo-QueryString {
    <#
        .SYNOPSIS
        Convert an object to a query string

        .DESCRIPTION
        Convert an object to a query string

        .EXAMPLE
        ConvertTo-QueryString -InputObject @{a=1;b=2}

        ?a=1&b=2

        .EXAMPLE
        ConvertTo-QueryString -InputObject @{a='this is value of a';b='valueOfB'}

        ?a=this%20is%20value%20of%20a&b=valueOfB

        .EXAMPLE
        ConvertTo-QueryString -InputObject @{a='this is value of a';b='valueOfB'} -AsURLEncoded

        ?a=this+is+value+of+a&b=valueOfB
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [object] $InputObject,

        [Parameter()]
        [switch] $AsURLEncoded
    )

    if ($InputObject -isnot [hashtable]) {
        $InputObject = $InputObject | ConvertTo-HashTable
    }

    $parameters = if ($AsURLEncoded) {
        ($InputObject.GetEnumerator() | ForEach-Object {
            "$([System.Web.HttpUtility]::UrlEncode($_.Key))=$([System.Web.HttpUtility]::UrlEncode($_.Value))"
        }) -join '&'
    } else {
        ($InputObject.GetEnumerator() | ForEach-Object {
            "$([System.Uri]::EscapeDataString($_.Key))=$([System.Uri]::EscapeDataString($_.Value))"
        }) -join '&'
    }

    if ($parameters) {
        '?' + $parameters
    }
}
