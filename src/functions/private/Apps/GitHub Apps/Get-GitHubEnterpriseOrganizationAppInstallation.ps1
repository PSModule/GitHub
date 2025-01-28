function Get-GitHubEnterpriseOrganizationAppInstallation {
    <#
        .SYNOPSIS
        List GitHub Apps installed on an enterprise-owned organization

        .DESCRIPTION
        Lists the GitHub App installations associated with the given enterprise-owned organization.

        The authenticated GitHub App must be installed on the enterprise and be granted the Enterprise/organization_installations (read) permission.

        .EXAMPLE
        Get-GitHubEnterpriseOrganizationAppInstallation -ENterprise 'msx' -Organization 'github'

        Gets all GitHub Apps in the organization `github` in the enterprise `msx`.

        .NOTES
        [List GitHub Apps installed on an enterprise-owned organization]()
    #>
    [OutputType([pscustomobject])]
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

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        try {
            $body = @{
                per_page = $PerPage
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/enterprises/$Enterprise/apps/organizations/$Organization/installations"
                Method      = 'GET'
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
