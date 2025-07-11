﻿function Get-GitHubAppInstallableOrganization {
    <#
        .SYNOPSIS
        Get enterprise-owned organizations that can have GitHub Apps installed

        .DESCRIPTION
        List of organizations owned by the enterprise on which the authenticated GitHub App installation may install other GitHub Apps.

        .NOTES
        Permissions required:
        - enterprise_organization_installations: read

        .EXAMPLE
        Get-GitHubAppInstallableOrganization -Enterprise 'msx'

        .OUTPUTS
        GitHubOrganization[]

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App/Get-GitHubAppInstallableOrganization
    #>
    [OutputType([GitHubOrganization[]])]
    [CmdletBinding()]
    param(
        # The enterprise slug or ID.
        [Parameter(Mandatory)]
        [string] $Enterprise,

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, UAT
        # enterprise_organization_installations=read
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/enterprises/$Enterprise/apps/installable_organizations"
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            foreach ($organization in $_.Response) {
                [GitHubOrganization]::new($organization, $Context)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
