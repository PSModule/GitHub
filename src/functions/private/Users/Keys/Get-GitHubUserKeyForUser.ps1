filter Get-GitHubUserKeyForUser {
    <#
        .SYNOPSIS
        List public SSH keys for a user

        .DESCRIPTION
        Lists the _verified_ public SSH keys for a user. This is accessible by anyone.

        .EXAMPLE
        Get-GitHubUserKeyForUser -Username 'octocat'

        Gets all public SSH keys for the 'octocat' user.

        .NOTES
        https://docs.github.com/rest/users/keys#list-public-keys-for-a-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Username,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30,

        # The context to run the command in.
        [Parameter()]
        [string] $Context
    )

    $body = @{
        per_page = $PerPage
    }

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/users/$Username/keys"
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
