filter Get-GitHubUserGpgKeyForUser {
    <#
        .SYNOPSIS
        List GPG keys for a user

        .DESCRIPTION
        Lists the GPG keys for a user. This information is accessible by anyone.

        .EXAMPLE
        Get-GitHubUserGpgKeyForUser -Username 'octocat'

        Gets all GPG keys for the 'octocat' user.

        .NOTES
        https://docs.github.com/rest/users/gpg-keys#list-gpg-keys-for-a-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Username,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30
    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case
    Remove-HashtableEntry -Hashtable $body -RemoveNames 'username'

    $inputObject = @{
        APIEndpoint = "/users/$Username/gpg_keys"
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
