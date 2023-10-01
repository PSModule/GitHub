filter Assert-GitHubOrganizationBlockedUser {
    <#
        .SYNOPSIS
        Check if a user is blocked by an organization

        .DESCRIPTION
        Returns a 204 if the given user is blocked by the given organization. Returns a 404 if the organization is not blocking the user, or if the user account has been identified as spam by GitHub.

        .EXAMPLE
        Get-GitHubOrganizationBlockedUser -OrganizationName 'github'

        Lists all users blocked by the organization `github`.

        .NOTES
        https://docs.github.com/rest/orgs/blocking#check-if-a-user-is-blocked-by-an-organization
    #>
    [OutputType([pscustomobject])]
    [Alias('Is-GitHubOrganizationBlockedUser')]
    [Alias('Check-GitHubOrganizationBlockedUser')]
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
            ValueFromPipelineByPropertyName
        )]
        [string] $Username
    )

    $inputObject = @{
        APIEndpoint = "/orgs/$OrganizationName/blocks/$Username"
        Method      = 'GET'
    }

    try {
        (Invoke-GitHubAPI @inputObject).StatusCode -eq 204
    } catch {
        if ($_.Exception.Response.StatusCode.Value__ -eq 404) {
            return $false
        } else {
            throw $_
        }
    }
}
