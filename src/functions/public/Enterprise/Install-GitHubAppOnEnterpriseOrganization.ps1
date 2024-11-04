function Install-GitHubAppOnEnterpriseOrganization {
    <#
        .SYNOPSIS
        Install an app on an Enterprise-owned organization

        .DESCRIPTION
        Installs the provided GitHub App on the specified organization owned by the enterprise.

        The authenticated GitHub App must be installed on the enterprise and be granted the Enterprise/organization_installations (write) permission.

        .EXAMPLE
        Install-GitHubAppOnEnterpriseOrganization -Enterprise 'msx' -Organization 'org' -ClientID '123456'
    #>
    [CmdletBinding()]
    param(
        # The enterprise slug or ID.
        [Parameter(Mandatory)]
        [string] $Enterprise,

        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Organization,

        # The client ID of the GitHub App to install.
        [Parameter(Mandatory)]
        [string] $ClientID,

        # The repository selection for the GitHub App. Can be one of:
        # - all - all repositories that the authenticated GitHub App installation can access.
        # - selected - select specific repositories.
        [Parameter()]
        [ValidateSet('all', 'selected')]
        [string] $RepositorySelection = 'all',

        # The names of the repositories to which the installation will be granted access.
        [Parameter()]
        [string[]] $Repositories
    )

    $body = @{
        client_id            = $ClientID
        repository_selection = $RepositorySelection
        repositories         = $Repositories
    }
    $body | Remove-HashtableEntry -NullOrEmptyValues

    $inputObject = @{
        APIEndpoint = "/enterprises/$Enterprise/apps/organizations/$Organization/installations"
        Method      = 'Post'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
