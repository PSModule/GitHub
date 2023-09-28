function Get-GitHubMeta {
    <#
        .SYNOPSIS
        Get GitHub meta information.

        .DESCRIPTION
        Returns meta information about GitHub, including a list of GitHub's IP addresses. For more information, see "[About GitHub's IP addresses](https://docs.github.com/articles/about-github-s-ip-addresses/)."

        The API's response also includes a list of GitHub's domain names.

        The values shown in the documentation's response are example values. You must always query the API directly to get the latest values.

        **Note:** This endpoint returns both IPv4 and IPv6 addresses. However, not all features support IPv6. You should refer to the specific documentation for each feature to determine if IPv6 is supported.

        .EXAMPLE
        Get-GitHubMeta

        Returns meta information about GitHub, including a list of GitHub's IP addresses.

        .NOTES
        https://docs.github.com/rest/meta/meta#get-apiname-meta-information
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param ()

    $inputObject = @{
        ApiEndpoint = '/meta'
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject

}
