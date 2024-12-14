filter Get-GitHubUserMyFollowers {
    <#
        .SYNOPSIS
        List followers of the authenticated user

        .DESCRIPTION
        Lists the people following the authenticated user.

        .EXAMPLE
        Get-GitHubUserMyFollowers

        Gets all followers of the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/followers#list-followers-of-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Private function, not exposed to user.')]
    [CmdletBinding()]
    param(
        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
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
        APIEndpoint = '/user/followers'
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
