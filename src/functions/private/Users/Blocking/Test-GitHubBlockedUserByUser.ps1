filter Test-GitHubBlockedUserByUser {
    <#
        .SYNOPSIS
        Check if a user is blocked by the authenticated user

        .DESCRIPTION
        Returns a 204 if the given user is blocked by the authenticated user.
        Returns a 404 if the given user is not blocked by the authenticated user,
        or if the given user account has been identified as spam by GitHub.

        .EXAMPLE
        Test-GitHubBlockedUserByUser -Username 'octocat'

        Checks if the user `octocat` is blocked by the authenticated user.
        Returns true if the user is blocked, false if not.

        .NOTES
        https://docs.github.com/rest/users/blocking#check-if-a-user-is-blocked-by-the-authenticated-user
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('login')]
        [string] $Username,

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
        APIEndpoint = "/user/blocks/$Username"
        Method      = 'GET'
        Body        = $body
    }

    try {
        (Invoke-GitHubAPI @inputObject).StatusCode -eq 204
    } catch {
        if ($_.Exception.Response.StatusCode.Value__ -eq 404) {
            return $false
        } else {
            throw $_
        }
    }

}
