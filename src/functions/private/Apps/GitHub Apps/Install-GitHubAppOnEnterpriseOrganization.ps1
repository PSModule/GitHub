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
    [OutputType([GitHubAppInstallation])]
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
        [Parameter(Mandatory)]
        [ValidateSet('all', 'selected', 'none')]
        [string] $RepositorySelection,

        # The names of the repositories to which the installation will be granted access.
        [Parameter()]
        [string[]] $Repositories,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, UAT
        # enterprise_organization_installations=write
    }

    process {
        if ($RepositorySelection) {
            $RepositorySelection = $RepositorySelection.ToLower()
        }
        $body = @{
            client_id            = $ClientID
            repository_selection = $RepositorySelection
            repositories         = $Repositories
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $apiParams = @{
            Method      = 'POST'
            APIEndpoint = "/enterprises/$Enterprise/apps/organizations/$Organization/installations"
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            [GitHubAppInstallation]::new($_.Response)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
