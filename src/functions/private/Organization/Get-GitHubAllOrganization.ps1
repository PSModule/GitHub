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

        .OUTPUTS
        GitHubOrganization

        .NOTES
        [List organizations](https://docs.github.com/rest/orgs/orgs#list-organizations)
    #>
    [OutputType([GitHubOrganization])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding()]
    param(
        # A organization ID. Only return organizations with an ID greater than this ID.
        [Parameter()]
        [int] $Since = 0,

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

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
            since = $Since
        }

        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = '/organizations'
            Body        = $body
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            foreach ($organization in $_.Response) {
                $organization | Add-Member -NotePropertyName Url -NotePropertyValue "$($Context.HostName)/$($organization.login)" -Force
                [GitHubOrganization]::new($organization)
            }
        }
    }
    end {
        Write-Debug "[$stackPath] - End"
    }
}
