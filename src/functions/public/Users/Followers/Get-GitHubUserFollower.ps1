﻿filter Get-GitHubUserFollower {
    <#
        .SYNOPSIS
        List followers of a given user or the authenticated user

        .DESCRIPTION
        Lists the people following a given user or the authenticated user.

        .EXAMPLE
        Get-GitHubUserFollower

        Gets all followers of the authenticated user.

        .EXAMPLE
        Get-GitHubUserFollower -Username 'octocat'

        Gets all followers of the user 'octocat'.

        .NOTES
        [List followers of the authenticated user](https://docs.github.com/rest/users/followers#list-followers-of-the-authenticated-user)
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
        if ($Username) {
            Get-GitHubUserFollowersOfUser -Username $Username -PerPage $PerPage -Context $Context
        } else {
            Get-GitHubUserMyFollower -PerPage $PerPage -Context $Context
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
