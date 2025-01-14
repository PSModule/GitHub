﻿function Get-GitHubEnterpriseInstallableOrganization {
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
    #SkipTest:FunctionTest:Will add a test for this function in a future PR
    [CmdletBinding()]
    param(
        # The enterprise slug or ID.
        [Parameter()]
        [string] $Enterprise,

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
            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/enterprises/$Enterprise/apps/installable_organizations"
                Method      = 'GET'
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
