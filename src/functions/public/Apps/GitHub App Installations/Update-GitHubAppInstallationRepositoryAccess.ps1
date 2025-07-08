function Update-GitHubAppInstallationRepositoryAccess {
    <#
        .SYNOPSIS
        Update the installation repository access between all repositories and selected repositories.

        .DESCRIPTION
        Update repository access for a GitHub App installation between all repositories and selected repositories.

        .EXAMPLE
        Update-GitHubAppInstallationRepositoryAccess -Enterprise 'msx' -Organization 'PSModule' -InstallationID 12345678 -RepositorySelection 'all'

        Update the repository access for the GitHub App installation with the ID '12345678'
        to all repositories on the organization 'PSModule' in the enterprise 'msx'.

        .EXAMPLE
        $params = @{
            Enterprise          = 'msx'
            Organization        = 'PSModule'
            InstallationID      = 12345678
            RepositorySelection = 'selected'
            Repositories        = 'repo1', 'repo2'
        }
        Update-GitHubAppInstallationRepositoryAccess @params

        Update the repository access for the GitHub App installation with the ID '12345678'
        to the repositories 'repo1' and 'repo2' on the organization 'PSModule' in the enterprise 'msx'.

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App%20Installations/Update-GitHubAppInstallationRepositoryAccess
    #>
    [CmdletBinding(SupportsShouldProcess)]
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
            ValueFromPipelineByPropertyName)]
        [string] $Organization,

        # The unique identifier of the installation.
        # Example: '12345678'
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('installation_id', 'InstallationID')]
        [int] $ID,

        # The repository selection for the GitHub App. Can be one of:
        # - all - all repositories that the authenticated GitHub App installation can access.
        # - selected - select specific repositories.
        [Parameter(Mandatory)]
        [ValidateSet('all', 'selected')]
        [string] $RepositorySelection,

        # The names of the repositories to which the installation will be granted access.
        [Parameter()]
        [string[]] $Repositories = @(),

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
        #enterprise_organization_installation_repositories=write
        #enterprise_organization_installations=write
    }

    process {
        $body = @{
            repository_selection = $RepositorySelection
            repositories         = $Repositories
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $apiParams = @{
            Method      = 'PATCH'
            APIEndpoint = "/enterprises/$Enterprise/apps/organizations/$Organization/installations/$ID/repositories"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("$Enterprise/$Organization", 'Update repository access')) {
            Invoke-GitHubAPI @apiParams | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
