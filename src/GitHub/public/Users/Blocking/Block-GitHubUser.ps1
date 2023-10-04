filter Block-GitHubUser {
    <#
        .SYNOPSIS
        Block a user

        .DESCRIPTION
        Blocks the given user and returns a 204. If the authenticated user cannot block the given user a 422 is returned.

        .PARAMETER Username
        Parameter description

        .EXAMPLE
        Block-GitHubUser -Username 'octocat'

        Blocks the user 'octocat' for the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/blocking#block-a-user
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
        Method      = 'PUT'
    }

    try {
        $null = (Invoke-GitHubAPI @inputObject)
        # Should we check if user is already blocked and return true if so?
        return $true
    } catch {
        if ($_.Exception.Response.StatusCode.Value__ -eq 422) {
            return $false
        } else {
            Write-Error $_.Exception.Response
            throw $_
        }
    }
}
