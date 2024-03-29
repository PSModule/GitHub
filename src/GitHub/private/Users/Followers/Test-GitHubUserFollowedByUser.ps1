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
    param (
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
        [string] $Follows
    )

    $inputObject = @{
        APIEndpoint = "/users/$Username/following/$Follows"
        Method      = 'GET'
    }

    try {
        $null = (Invoke-GitHubAPI @inputObject)
        return $true
    } catch {
        if ($_.Exception.Response.StatusCode.Value__ -eq 404) {
            return $false
        } else {
            throw $_
        }
    }
}
