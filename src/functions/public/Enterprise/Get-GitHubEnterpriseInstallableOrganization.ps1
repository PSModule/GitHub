function Get-GitHubEnterpriseInstallableOrganization {
    <#
        .SYNOPSIS
        Get enterprise-owned organizations that can have GitHub Apps installed

        .DESCRIPTION
        List of organizations owned by the enterprise on which the authenticated GitHub App installation may install other GitHub Apps.

        The authenticated GitHub App must be installed on the enterprise and be granted the Enterprise/enterprise_organization_installations
        (read) permission.

        .EXAMPLE
        Get-GitHubEnterpriseInstallableOrganization -Enterprise 'msx'
    #>
    [CmdletBinding()]
    param(
        # The enterprise slug or ID.
        [Parameter(Mandatory)]
        [string] $Enterprise
    )
    $inputObject = @{
        APIEndpoint = "/enterprises/$Enterprise/apps/installable_organizations"
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
