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
    param(
        # A organization ID. Only return organizations with an ID greater than this ID.
        [Parameter()]
        [int] $Since = 0,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            since    = $Since
            per_page = $PerPage
        }

        $inputObject = @{
            Method      = 'Get'
            APIEndpoint = '/organizations'
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
    end {
        Write-Debug "[$stackPath] - End"
    }
}
