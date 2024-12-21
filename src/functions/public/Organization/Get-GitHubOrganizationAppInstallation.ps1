filter Get-GitHubOrganizationAppInstallation {
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
    #SkipTest:FunctionTest:Will add a test for this function in a future PR
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('org')]
        [Alias('owner')]
        [Alias('login')]
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
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner: [$Owner]"
    }

    process {
        try {
            $body = @{
                per_page = $PerPage
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/orgs/$Organization/installations"
                Method      = 'GET'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response.installations
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
