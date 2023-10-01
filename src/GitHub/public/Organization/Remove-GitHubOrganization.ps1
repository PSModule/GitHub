filter Remove-GitHubOrganization {
    <#
        .SYNOPSIS
        Delete an organization

        .DESCRIPTION
        Deletes an organization and all its repositories.
        The organization login will be unavailable for 90 days after deletion.
        Please review the Terms of Service regarding account deletion before using this endpoint:
        https://docs.github.com/site-policy/github-terms/github-terms-of-service

        .EXAMPLE
        Remove-GitHubOrganization -OrganizationName 'github'

        Deletes the organization 'github' and all its repositories.

        .NOTES
        https://docs.github.com/rest/orgs/orgs#delete-an-organization
    #>
    [OutputType([pscustomobject])]
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
        [string] $OrganizationName
    )

    $inputObject = @{
        APIEndpoint = "/orgs/$OrganizationName"
        Method      = 'DELETE'
    }

    (Invoke-GitHubAPI @inputObject).Response

}
