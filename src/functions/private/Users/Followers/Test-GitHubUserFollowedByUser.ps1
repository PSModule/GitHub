filter Test-GitHubUserFollowedByUser {
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
        $inputObject = @{
            Context     = $Context
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

    end {
        Write-Debug "[$stackPath] - End"
    }
}
