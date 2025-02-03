filter Test-GitHubUserFollowedByMe {
    <#
        .SYNOPSIS
        Check if a person is followed by the authenticated user

        .DESCRIPTION
        Returns a 204 if the given user is followed by the authenticated user.
        Returns a 404 if the user is not followed by the authenticated user.

        .EXAMPLE
        Test-GitHubUserFollowedByMe -Username 'octocat'

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
        [string] $Username,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [GitHubContext] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Context     = $Context
            APIEndpoint = "/user/following/$Username"
            Method      = 'Get'
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

    end {
        Write-Debug "[$stackPath] - End"
    }
}
