filter Get-GitHubUserFollowingUser {
    <#
        .SYNOPSIS
        List the people a user follows

        .DESCRIPTION
        Lists the people who the specified user follows.

        .EXAMPLE
        Get-GitHubUserFollowingUser -Username 'octocat'

        Gets all people that 'octocat' follows.

        .NOTES
        https://docs.github.com/rest/users/followers#list-the-people-a-user-follows

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
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
        [ValidateRange(1, 100)]
        [int] $PerPage = 30,

        # The context to run the command in.
        [Parameter()]
        [string] $Context
    )

    $body = @{
        per_page = $PerPage
    }

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/users/$Username/following"
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
