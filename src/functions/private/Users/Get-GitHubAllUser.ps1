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
        Get-GitHubAllUser -Since 17722253

        Get a list of users, starting with the user 'MariusStorhaug'.

        .NOTES
        https://docs.github.com/rest/users/users#list-users
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # A user ID. Only return users with an ID greater than this ID.
        [Parameter()]
        [int] $Since = 0,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        try {
            $body = @{
                since    = $Since
                per_page = $PerPage
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/users'
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
        Write-Debug "[$commandName] - End"
    }
}
