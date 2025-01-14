﻿function Install-GitHubAppOnEnterpriseOrganization {
    <#
    .SYNOPSIS
    Install an app on an Enterprise-owned organization

    .DESCRIPTION
    Installs the provided GitHub App on the specified organization owned by the enterprise.

    The authenticated GitHub App must be installed on the enterprise and be granted the Enterprise/organization_installations (write) permission.

    .EXAMPLE
    Install-GitHubAppOnEnterpriseOrganization -Enterprise 'msx' -Organization 'org' -ClientID '123456'
    #>
    #SkipTest:FunctionTest:Will add a test for this function in a future PR
    [CmdletBinding()]
    param(
        # The enterprise slug or ID.
        [Parameter()]
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
        [string[]] $Repositories,

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
        if ([string]::IsNullOrEmpty($Enterprise)) {
            $Enterprise = $Context.Enterprise
        }
        Write-Debug "Enterprise: [$Enterprise]"
    }

    process {
        try {
            $body = @{
                client_id            = $ClientID
                repository_selection = $RepositorySelection
                repositories         = $Repositories
            }
            $body | Remove-HashtableEntry -NullOrEmptyValues

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/enterprises/$Enterprise/apps/organizations/$Organization/installations"
                Method      = 'Post'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
