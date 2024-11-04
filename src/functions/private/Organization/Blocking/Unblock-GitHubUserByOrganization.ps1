filter Unblock-GitHubUserByOrganization {
    <#
        .SYNOPSIS
        Unblock a user from an organization

        .DESCRIPTION
        Unblocks the given user on behalf of the specified organization.

        .EXAMPLE
        Unblock-GitHubUserByOrganization -OrganizationName 'github' -Username 'octocat'

        Unblocks the user 'octocat' from the organization 'github'.
        Returns $true if successful.

        .NOTES
        https://docs.github.com/rest/orgs/blocking#unblock-a-user-from-an-organization
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
        [Alias('login')]
        [string] $Username
    )

    $inputObject = @{
        APIEndpoint = "/orgs/$OrganizationName/blocks/$Username"
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
