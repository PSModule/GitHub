function Get-GitHubAppAccessibleRepository {
    <#
        .SYNOPSIS
        Get repositories belonging to an enterprise owned organization that can be made accessible to a GitHub App

        .DESCRIPTION
        List the repositories belonging to an enterprise owned organization that can be made accessible to a GitHub App installed on that
        organization.

        The authenticated GitHub App must be installed on the enterprise and be granted the Enterprise/enterprise_organization_installations (read)
        permission.

        .EXAMPLE
        ```powershell
        $params = @{
            Enterprise   = 'msx'
            Organization = 'PSModule'
        }
        Get-GitHubAppAccessibleRepository @params
        ```

        Get the repositories that can be made accessible to a GitHub App installed on the organization 'PSModule' in the enterprise 'msx'.

        .OUTPUTS
        GitHubRepository[]

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App%20Installations/Get-GitHubAppAccessibleRepository
    #>
    [OutputType([GitHubRepository[]])]
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
            ValueFromPipelineByPropertyName
        )]
        [string] $Organization,

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
        # Enterprise organization installations (read)
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/enterprises/$Enterprise/apps/installable_organizations/$Organization/accessible_repositories"
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            foreach ($repo in $_.Response) {
                [GitHubRepository]@{
                    ID       = $repo.id
                    Name     = $repo.name
                    Owner    = [GitHubOwner]@{
                        Name = $Organization
                    }
                    FullName = $repo.full_name
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
