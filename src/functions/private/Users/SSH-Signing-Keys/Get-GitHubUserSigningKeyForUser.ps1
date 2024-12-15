filter Get-GitHubUserSigningKeyForUser {
    <#
        .SYNOPSIS
        List SSH signing keys for a user

        .DESCRIPTION
        List SSH signing keys for a user

        .EXAMPLE
        Get-GitHubUserSigningKeyForUser -Username 'octocat'

        Gets the SSH signing keys for the user 'octocat'.

        .NOTES
        https://docs.github.com/rest/users/ssh-signing-keys#list-ssh-signing-keys-for-a-user

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
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    $body = @{
        per_page = $PerPage
    }

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/users/$Username/ssh_signing_keys"
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
