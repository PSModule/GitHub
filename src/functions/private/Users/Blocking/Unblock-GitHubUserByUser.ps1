filter Unblock-GitHubUserByUser {
    <#
        .SYNOPSIS
        Unblock a user

        .DESCRIPTION
        Unblocks the given user and returns a 204.

        .EXAMPLE
        Unblock-GitHubUserByUser -Username 'octocat'

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
        [Parameter()]
        [GitHubContext] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        try {
            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/user/blocks/$Username"
                Method      = 'DELETE'
            }

            try {
                $null = (Invoke-GitHubAPI @inputObject)
                return $true
            } catch {
                Write-Error $_.Exception.Response
                throw $_
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
