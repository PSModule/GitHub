function Get-GitHubMeta {
    <#
    .SYNOPSIS
    Returns meta information about GitHub, including a list of GitHub's IP addresses.

    .DESCRIPTION
    Returns meta information about GitHub, including a list of GitHub's IP addresses.

    The API's response also includes a list of GitHub's domain names.

    The values shown in the documentation's response are example values. You must always query the API directly to get the latest values.

    Note: This endpoint returns both IPv4 and IPv6 addresses. However, not all features support IPv6. You should refer to the specific documentation for each feature to determine if IPv6 is supported.

    .EXAMPLE
    Get-GitHubMeta

    Returns meta information about GitHub, including a list of GitHub's IP addresses.

    .NOTES
    https://docs.github.com/en/rest/meta/meta?apiVersion=2022-11-28#github-api-root
    https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-githubs-ip-addresses
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param ()

    $inputObject = @{
        ApiEndpoint = '/meta'
        Method      = 'GET'
    }

    $response = Invoke-GitHubAPI @inputObject

    $response
}
