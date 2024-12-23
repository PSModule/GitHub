filter Set-GitHubOrganizationSecurityFeature {
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
        Set-GitHubOrganizationSecurityFeature -Organization 'github' -SecurityProduct 'dependency_graph' -Enablement 'enable_all'

        Enable the dependency graph for all repositories in the organization `github`.

        .NOTES
        [Enable or disable a security feature for an organization](https://docs.github.com/rest/orgs/orgs#enable-or-disable-a-security-feature-for-an-organization)
    #>
    #SkipTest:FunctionTest:Will add a test for this function in a future PR
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Long link in notes.')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('org')]
        [Alias('owner')]
        [Alias('login')]
        [string] $Organization,

        # The security feature to enable or disable.
        [Parameter(Mandatory)]
        [Alias('security_product')]
        [ValidateSet(
            'dependency_graph',
            'dependabot_alerts',
            'dependabot_security_updates',
            'advanced_security',
            'code_scanning_default_setup',
            'secret_scanning',
            'secret_scanning_push_protection'
        )]
        [string] $SecurityProduct,

        # The action to take.
        # enable_all means to enable the specified security feature for all repositories in the organization. disable_all
        # means to disable the specified security feature for all repositories in the organization.
        [Parameter(Mandatory)]
        [ValidateSet(
            'enable_all',
            'disable_all'
        )]
        [string] $Enablement,

        # CodeQL query suite to be used. If you specify the query_suite parameter, the default setup will be configured with
        # this query suite only on all repositories that didn't have default setup already configured. It will not change the
        # query suite on repositories that already have default setup configured. If you don't specify any query_suite in your
        # request, the preferred query suite of the organization will be applied.
        [Parameter()]
        [Alias('query_suite')]
        [ValidateSet(
            'default',
            'extended'
        )]
        [string] $QuerySuite,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner: [$Owner]"
    }

    process {
        try {
            $body = @{
                query_suite = $QuerySuite
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/orgs/$Organization/$SecurityProduct/$Enablement"
                Method      = 'POST'
                Body        = $body
            }

            if ($PSCmdlet.ShouldProcess("security feature [$SecurityProduct] on organization [$Organization]", 'Set')) {
                Invoke-GitHubAPI @inputObject | ForEach-Object {
                    Write-Output $_.Response
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
