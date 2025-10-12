filter Unblock-GitHubUserByUser {
    <#
        .SYNOPSIS
        Unblock a user

        .DESCRIPTION
        Unblocks the given user and returns a 204.

        .EXAMPLE
        ```pwsh
        Unblock-GitHubUserByUser -Username 'octocat'
        ```

        Unblocks the user 'octocat' for the authenticated user.
        Returns $true if successful.

        .NOTES
        https://docs.github.com/rest/users/blocking#unblock-a-user
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
            Method      = 'DELETE'
            APIEndpoint = "/user/blocks/$Username"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
