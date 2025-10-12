filter Get-GitHubAllUser {
    <#
        .SYNOPSIS
        List users

        .DESCRIPTION
        Lists all users, in the order that they signed up on GitHub. This list includes personal user accounts and organization accounts.

        Note: Pagination is powered exclusively by the `since` parameter. Use the
        [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers)
        to get the URL for the next page of users.

        .EXAMPLE
        ```powershell
        Get-GitHubAllUser -Since 17722253
        ```

        Get a list of users, starting with the user 'MariusStorhaug'.

        .OUTPUTS
        GitHubUser

        .NOTES
        [List users](https://docs.github.com/rest/users/users#list-users)
    #>
    [OutputType([GitHubUser])]
    [CmdletBinding()]
    param(
        # A user ID. Only return users with an ID greater than this ID.
        [Parameter()]
        [int] $Since = 0,

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

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
        $body = @{
            since = $Since
        }

        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = '/users'
            Body        = $body
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            foreach ($account in $_.Response) {
                if ($account.type -eq 'Organization') {
                    [GitHubOrganization]::New($account, $Context)
                } elseif ($account.type -eq 'User') {
                    [GitHubUser]::New($account)
                } else {
                    [GitHubOwner]::New($account)
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
