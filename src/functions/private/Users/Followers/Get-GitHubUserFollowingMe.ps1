filter Get-GitHubUserFollowingMe {
    <#
        .SYNOPSIS
        List the people the authenticated user follows

        .DESCRIPTION
        Lists the people who the authenticated user follows.

        .EXAMPLE
        Get-GitHubUserFollowingMe

        Gets all people the authenticated user follows.

        .NOTES
        https://docs.github.com/rest/users/followers#list-the-people-the-authenticated-user-follows

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    $body = @{
        per_page = $PerPage
    }

    $inputObject = @{
        Context     = $Context
        APIEndpoint = '/user/following'
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
