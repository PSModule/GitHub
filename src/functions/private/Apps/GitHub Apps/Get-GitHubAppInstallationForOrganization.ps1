function Get-GitHubAppInstallationForOrganization {
    <#
        .SYNOPSIS
        List app installations for an organization

        .DESCRIPTION
        Lists all GitHub Apps in an organization. The installation count includes all GitHub Apps installed on repositories in the organization.
        You must be an organization owner with `admin:read` scope to use this endpoint.

        .EXAMPLE
        ```powershell
        Get-GitHubAppInstallationForOrganization -Organization 'github'
        ```

        Gets all GitHub Apps in the organization `github`.

        .OUTPUTS
        GitHubAppInstallation

        .NOTES
        [List app installations for an organization](https://docs.github.com/rest/orgs/orgs#list-app-installations-for-an-organization)
    #>
    [OutputType([GitHubAppInstallation])]
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
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/orgs/$Organization/installations"
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            foreach ($installation in $_.Response.installations) {
                [GitHubAppInstallation]::new($installation)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
