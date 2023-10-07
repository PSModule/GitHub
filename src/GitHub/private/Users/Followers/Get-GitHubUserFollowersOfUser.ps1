filter Get-GitHubUserFollowersOfUser {
    <#
        .SYNOPSIS
        List followers of a user

        .DESCRIPTION
        Lists the people following the specified user.

        .EXAMPLE
        Get-GitHubUserFollowersOfUser -Username 'octocat'

        Gets all followers of user 'octocat'.

        .NOTES
        https://docs.github.com/rest/users/followers#list-followers-of-a-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('login')]
        [string] $Username,

        # The number of results per page (max 100).
        [Parameter()]
        [int] $PerPage = 30
    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case
    Remove-HashtableEntries -Hashtable $body -RemoveNames 'username'

    $inputObject = @{
        APIEndpoint = "/users/$Username/followers"
        Method      = 'GET'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response

}
