function Get-GitHubAppInstallation {
    <#
        .SYNOPSIS
        List installations for the authenticated app, on organization or enterprise organization.

        .DESCRIPTION
        Lists the installations for the authenticated app.
        If the app is installed on an enterprise, the installations for the enterprise are returned.
        If the app is installed on an organization, the installations for the organization are returned.
    #>
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        # The enterprise slug or ID.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Enterprise'
        )]
        [string] $Enterprise,

        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Enterprise'
        )]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Organization'
        )]
        [string] $Organization,

        # The number of results per page (max 100).
        [Parameter(
            ParameterSetName = 'Enterprise'
        )]
        [Parameter(
            ParameterSetName = 'Organization'
        )]
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
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Enterprise' {
                $params = @{
                    Enterprise   = $Enterprise
                    Organization = $Organization
                    PerPage      = $PerPage
                    Context      = $Context
                }
                Get-GitHubEnterpriseOrganizationAppInstallation @params
            }
            'Organization' {
                $params = @{
                    Organization = $Organization
                    PerPage      = $PerPage
                    Context      = $Context
                }
                Get-GitHubOrganizationAppInstallation @params
            }
            default {
                Get-GitHubAppInstallationForAuthenticatedApp -Context $Context
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
