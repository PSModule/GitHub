filter Remove-GitHubOrganization {
    <#
        .SYNOPSIS
        Delete an organization

        .DESCRIPTION
        Deletes an organization and all its repositories.
        The organization login will be unavailable for 90 days after deletion.
        Please review the [GitHub Terms of Service](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
        regarding account deletion before using this endpoint.

        .EXAMPLE
        Remove-GitHubOrganization -OrganizationName 'GitHub'

        Deletes the organization 'GitHub' and all its repositories.

        .NOTES
        [Delete an organization](https://docs.github.com/rest/orgs/orgs#delete-an-organization)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
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

    if ($PSCmdlet.ShouldProcess("organization [$OrganizationName]", 'Delete')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

}
