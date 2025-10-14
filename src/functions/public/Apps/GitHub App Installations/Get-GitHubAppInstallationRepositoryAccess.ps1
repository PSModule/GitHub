function Get-GitHubAppInstallationRepositoryAccess {
    <#
        .SYNOPSIS
        Get the repositories accessible to a given GitHub App installation.

        .DESCRIPTION
        Lists the repositories accessible to a given GitHub App installation on an enterprise-owned organization.

        The authenticated GitHub App must be installed on the enterprise and be granted the Enterprise/organization_installations (read) permission.

        .EXAMPLE
        ```powershell
        $params = @{
            Enterprise          = 'msx'
            Organization        = 'PSModule'
            InstallationID      = 12345678
        }
        Get-GitHubAppInstallationRepositoryAccess @params
        ```

        Get the repositories accessible to the GitHub App installation
        with the ID '12345678' on the organization 'PSModule' in the enterprise 'msx'.

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App%20Installations/Get-GitHubAppInstallationRepositoryAccess
    #>
    [CmdletBinding()]
    param(
        # The enterprise slug or ID.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Enterprise,

        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Organization,

        # The unique identifier of the installation.
        # Example: '12345678'
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('installation_id', 'InstallationID')]
        [int] $ID,

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, UAT
        #enterprise_organization_installation_repositories=read
        #enterprise_organization_installations=read
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/enterprises/$Enterprise/apps/organizations/$Organization/installations/$ID/repositories"
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
