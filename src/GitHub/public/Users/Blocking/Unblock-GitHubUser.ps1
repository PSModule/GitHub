filter Unblock-GitHubUser {
    <#
        .SYNOPSIS
        Unblock a user

        .DESCRIPTION
        Unblocks the given user and returns a 204.

        .EXAMPLE
        Unblock-GitHubUser -Username 'octocat'

        Unblocks the user 'octocat' for the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/blocking#unblock-a-user
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param (
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('login')]
        [string] $Username
    )

    $inputObject = @{
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
}
