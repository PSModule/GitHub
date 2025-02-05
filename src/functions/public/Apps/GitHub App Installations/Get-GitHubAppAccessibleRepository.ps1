﻿function Get-GitHubAppAccessibleRepository {
    <#
        .SYNOPSIS
        Get repositories belonging to an enterprise owned organization that can be made accessible to a GitHub App

        .DESCRIPTION
        List the repositories belonging to an enterprise owned organization that can be made accessible to a GitHub App installed on that
        organization.

        The authenticated GitHub App must be installed on the enterprise and be granted the Enterprise/enterprise_organization_installations (read)
        permission.

        .EXAMPLE
        $params = @{
            Enterprise   = 'msx'
            Organization = 'PSModule'
        }
        Get-GitHubAppAccessibleRepository @params

        Get the repositories that can be made accessible to a GitHub App installed on the organization 'PSModule' in the enterprise 'msx'.
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
            ValueFromPipelineByPropertyName
        )]
        [string] $Organization,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, UAT
        # Enterprise organization installations (read)
    }

    process {
        $body = @{
            per_page = $PerPage
        }

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/enterprises/$Enterprise/apps/installable_organizations/$Organization/accessible_repositories"
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
