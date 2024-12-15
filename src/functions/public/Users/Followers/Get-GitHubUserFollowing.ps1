filter Get-GitHubUserFollowing {
    <#
        .SYNOPSIS
        List the people a given user or the authenticated user follows

        .DESCRIPTION
        Lists the people who a given user or the authenticated user follows.

        .EXAMPLE
        Get-GitHubUserFollowing

        Gets all people the authenticated user follows.

        .EXAMPLE
        Get-GitHubUserFollowing -Username 'octocat'

        Gets all people that 'octocat' follows.

        .NOTES
        [List the people the authenticated user follows](https://docs.github.com/rest/users/followers#list-the-people-the-authenticated-user-follows)
        [List the people a user follows](https://docs.github.com/rest/users/followers#list-the-people-a-user-follows)

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The handle for the GitHub user account.
        [Parameter(
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

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        try {
            if ($Username) {
                Get-GitHubUserFollowingUser -Username $Username -PerPage $PerPage -Context $Context
            } else {
                Get-GitHubUserFollowingMe -PerPage $PerPage -Context $Context
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
