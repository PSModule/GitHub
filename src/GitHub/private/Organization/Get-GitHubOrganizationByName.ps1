function Get-GitHubOrganizationByName {
    <#
        .SYNOPSIS
        Get an organization

        .DESCRIPTION
        To see many of the organization response values, you need to be an authenticated organization owner with the `admin:org` scope. When the value of `two_factor_requirement_enabled` is `true`, the organization requires all members, billing managers, and outside collaborators to enable [two-factor authentication](https://docs.github.com/articles/securing-your-account-with-two-factor-authentication-2fa/).

        GitHub Apps with the `Organization plan` permission can use this endpoint to retrieve information about an organization's GitHub plan. See "[Authenticating with GitHub Apps](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/)" for details. For an example response, see 'Response with GitHub plan information' below."

        .EXAMPLE
        Get-GitHubOrganizationByName -OrganizationName 'github'

        Get the 'GitHub' organization

        .NOTES
        https://docs.github.com/rest/orgs/orgs#get-an-organization
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
        [Alias('name')]
        [Alias('login')]
        [string] $OrganizationName
    )

    begin {}

    process {

        $inputObject = @{
            APIEndpoint = "/orgs/$OrganizationName"
            Method      = 'GET'
        }

        Invoke-GitHubAPI @inputObject

    }

    end {}

}
