function Get-GitHubOrganizationAppInstallation {
    <#
        .SYNOPSIS
        List app installations for an organization

        .DESCRIPTION
        Lists all GitHub Apps in an organization. The installation count includes all GitHub Apps installed on repositories in the organization.
        You must be an organization owner with `admin:read` scope to use this endpoint.

        .EXAMPLE
        Get-GitHubOrganizationAppInstallation -Organization 'github'

        Gets all GitHub Apps in the organization `github`.

        .NOTES
        [List app installations for an organization](https://docs.github.com/rest/orgs/orgs#list-app-installations-for-an-organization)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Organization,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/orgs/$Organization/installations"
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response.installations
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
