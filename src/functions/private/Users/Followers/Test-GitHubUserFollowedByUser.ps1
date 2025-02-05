﻿filter Test-GitHubUserFollowedByUser {
    <#
        .SYNOPSIS
        Check if a user follows another user

        .DESCRIPTION
        Checks if a user follows another user.

        .EXAMPLE
        Test-GitHubUserFollowedByUser -Username 'octocat' -Follows 'ratstallion'

        Checks if the user 'octocat' follows the user 'ratstallion'.

        .NOTES
        https://docs.github.com/rest/users/followers#check-if-a-user-follows-another-user

    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Username,

        # The handle for the GitHub user account we want to check if user specified by $Username is following.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Follows,

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
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/users/$Username/following/$Follows"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
