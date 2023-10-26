filter Get-GitHubAllOrganization {
    <#
        .SYNOPSIS
        List organizations

        .DESCRIPTION
        Lists all organizations, in the order that they were created on GitHub.

        **Note:** Pagination is powered exclusively by the `since` parameter.
        Use the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers) to get the URL for the next page of organizations.

        .EXAMPLE
        Get-GitHubAllOrganization -Since 142951047

        List organizations, starting with PSModule

        .NOTES
        https://docs.github.com/rest/orgs/orgs#list-organizations

    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding()]
    param (
        # A organization ID. Only return organizations with an ID greater than this ID.
        [Parameter()]
        [int] $Since = 0,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30
    )

    $body = @{
        since    = $Since
        per_page = $PerPage
    }

    $inputObject = @{
        APIEndpoint = '/organizations'
        Method      = 'GET'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response

}
