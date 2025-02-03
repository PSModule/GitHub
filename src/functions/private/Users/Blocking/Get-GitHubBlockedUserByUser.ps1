filter Get-GitHubBlockedUserByUser {
    <#
        .SYNOPSIS
        List users blocked by the authenticated user

        .DESCRIPTION
        List the users you've blocked on your personal account.

        .EXAMPLE
        Get-GitHubBlockedUserByUser

        Returns a list of users blocked by the authenticated user.

        .NOTES
        [List users blocked by the authenticated user](https://docs.github.com/rest/users/blocking#list-users-blocked-by-the-authenticated-user)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

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
            $body = @{
                per_page = $PerPage
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/user/blocks'
                Method      = 'GET'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
