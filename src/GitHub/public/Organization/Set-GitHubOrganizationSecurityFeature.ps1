function Set-GitHubOrganizationSecurityFeature {
    <#
        .SYNOPSIS
        Enable or disable a security feature for an organization

        .DESCRIPTION
        Enables or disables the specified security feature for all eligible repositories in an organization.

        To use this endpoint, you must be an organization owner or be member of a team with the security manager role.
        A token with the 'write:org' scope is also required.

        GitHub Apps must have the `organization_administration:write` permission to use this endpoint.

        For more information, see "[Managing security managers in your organization](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization)."

        .EXAMPLE
        Set-GitHubOrganizationSecurityFeature -OrganizationName 'github' -SecurityProduct 'dependency_graph' -Enablement 'enable_all'

        Enable the dependency graph for all repositories in the organization `github`.

        .NOTES
        https://docs.github.com/rest/orgs/orgs#enable-or-disable-a-security-feature-for-an-organization
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('org')]
        [Alias('owner')]
        [Alias('login')]
        [Alias('name')]
        [string] $OrganizationName,

        # The security feature to enable or disable.
        [Parameter(Mandatory)]
        [Alias('security_product')]
        [ValidateSet('dependency_graph', 'dependabot_alerts', 'dependabot_security_updates', 'advanced_security', 'code_scanning_default_setup', 'secret_scanning', 'secret_scanning_push_protection')]
        [string] $SecurityProduct,

        # The action to take.
        # enable_all means to enable the specified security feature for all repositories in the organization. disable_all means to disable the specified security feature for all repositories in the organization.
        [Parameter(Mandatory)]
        [ValidateSet('enable_all', 'disable_all')]
        [string] $Enablement,

        # CodeQL query suite to be used. If you specify the query_suite parameter, the default setup will be configured with this query suite only on all repositories that didn't have default setup already configured. It will not change the query suite on repositories that already have default setup configured. If you don't specify any query_suite in your request, the preferred query suite of the organization will be applied.
        [Parameter()]
        [Alias('query_suite')]
        [ValidateSet('default', 'extended')]
        [string] $QuerySuite
    )

    $body = @{
        query_suite = $QuerySuite
    }

    $inputObject = @{
        APIEndpoint = "/orgs/$OrganizationName/$SecurityProduct/$Enablement"
        Method      = 'PATCH'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject

}
