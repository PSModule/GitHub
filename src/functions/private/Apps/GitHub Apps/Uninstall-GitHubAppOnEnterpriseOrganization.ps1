function Uninstall-GitHubAppOnEnterpriseOrganization {
    <#
        .SYNOPSIS
        Uninstall a GitHub App from an enterprise-owned organization.

        .DESCRIPTION
        Uninstall a GitHub App from an enterprise-owned organization.

        The authenticated GitHub App must be installed on the enterprise and be granted the Enterprise/organization_installations (write) permission.

        .EXAMPLE
        Uninstall-GitHubAppOnEnterpriseOrganization -Enterprise 'github' -Organization 'octokit' -ID '123456'

        Uninstall the GitHub App with the installation ID `123456` from the organization `octokit` in the enterprise `github`.

        .NOTES
        [Uninstall a GitHub App from an enterprise-owned organization](https://docs.github.com/enterprise-cloud@latest/rest/enterprise-admin/organization-installations#uninstall-a-github-app-from-an-enterprise-owned-organization)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'Contains a long link.'
    )]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The enterprise slug or ID.
        [Parameter(Mandatory)]
        [string] $Enterprise,

        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Organization,

        # The ID of the GitHub App installation to uninstall.
        [Parameter(Mandatory)]
        [string] $ID,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, UAT
        #enterprise_organization_installations=write
    }

    process {
        $apiParams = @{
            Method      = 'DELETE'
            APIEndpoint = "/enterprises/$Enterprise/apps/organizations/$Organization/installations/$ID"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("GitHub App Installation: $Enterprise/$Organization/$ID", 'Uninstall')) {
            $null = Invoke-GitHubAPI @apiParams
            Write-Verbose "Successfully removed installation: $Enterprise/$Organization/$ID"
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
