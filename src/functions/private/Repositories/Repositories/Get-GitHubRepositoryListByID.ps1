﻿filter Get-GitHubRepositoryListByID {
    <#
        .SYNOPSIS
        List public repositories

        .DESCRIPTION
        Lists all public repositories in the order that they were created.

        Note:
        - For GitHub Enterprise Server, this endpoint will only list repositories available to all users on the enterprise.
        - Pagination is powered exclusively by the `since` parameter. Use the
        [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers)
        to get the URL for the next page of repositories.

        .EXAMPLE
        Get-GitHubRepositoryListByID -Since '123456789

        Gets the repositories with an ID equals and greater than 123456789.

        .NOTES
        https://docs.github.com/rest/repos/repos#list-public-repositories

    #>
    [CmdletBinding()]
    param(
        # A repository ID. Only return repositories with an ID greater than this ID.
        [Parameter()]
        [int] $Since = 0,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        try {
            $body = @{
                since = $Since
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/repositories'
                Method      = 'GET'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
