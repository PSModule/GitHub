filter Test-GitHubUserFollowedByMe {
    <#
        .SYNOPSIS
        Check if a person is followed by the authenticated user

        .DESCRIPTION
        Returns a 204 if the given user is followed by the authenticated user.
        Returns a 404 if the user is not followed by the authenticated user.

        .EXAMPLE
        ```pwsh
        Test-GitHubUserFollowedByMe -Username 'octocat'
        ```

        Checks if the authenticated user follows the user 'octocat'.

        .NOTES
        https://docs.github.com/rest/users/followers#check-if-a-person-is-followed-by-the-authenticated-user

    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('login')]
        [string] $Username,

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
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/user/following/$Username"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
