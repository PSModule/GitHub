filter Block-GitHubUserByOrganization {
    <#
        .SYNOPSIS
        Block a user from an organization

        .DESCRIPTION
        Blocks the given user on behalf of the specified organization and returns a 204.
        If the organization cannot block the given user a 422 is returned.

        .EXAMPLE
        Block-GitHubUserByOrganization -OrganizationName 'github' -Username 'octocat'

        Blocks the user 'octocat' from the organization 'github'.
        Returns $true if successful, $false if not.

        .NOTES
        https://docs.github.com/rest/orgs/blocking#block-a-user-from-an-organization
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param (
        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('org')]
        [Alias('owner')]
        [Alias('login')]
        [string] $OrganizationName,

        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Username,

        # The context to run the command in.
        [Parameter()]
        [string] $Context
    )

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/orgs/$OrganizationName/blocks/$Username"
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
