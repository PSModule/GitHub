filter Block-GitHubUserByUser {
    <#
        .SYNOPSIS
        Block a user

        .DESCRIPTION
        Blocks the given user and returns a 204. If the authenticated user cannot block the given user a 422 is returned.

        .EXAMPLE
        Block-GitHubUserByUser -Username 'octocat'

        Blocks the user 'octocat' for the authenticated user.
        Returns $true if successful, $false if not.

        .NOTES
        https://docs.github.com/rest/users/blocking#block-a-user
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
        $inputObject = @{
            Method      = 'Put'
            APIEndpoint = "/user/blocks/$Username"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
