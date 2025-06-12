function Get-GitHubAppInstallation {
    <#
        .SYNOPSIS
        List installations for the authenticated app, on organization or enterprise organization.

        .DESCRIPTION
        Lists the installations for the authenticated app.
        If the app is installed on an enterprise, the installations for the enterprise are returned.
        If the app is installed on an organization, the installations for the organization are returned.

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App%20Installations/Get-GitHubAppInstallation
    #>
    [OutputType([GitHubAppInstallation[]])]
    [CmdletBinding(DefaultParameterSetName = 'List installations for the authenticated app')]
    param(
        # The enterprise slug or ID.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'List installations on an Enterprise'
        )]
        [string] $Enterprise,

        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'List installations on an Enterprise'
        )]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'List installations on an Organization'
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
    }

    process {
        $params = @{
            PerPage = $PerPage
            Context = $Context
        }
        switch ($PSCmdlet.ParameterSetName) {
            'List installations on an Enterprise' {
                $params += @{
                    Enterprise   = $Enterprise
                    Organization = $Organization
                }
                Get-GitHubEnterpriseOrganizationAppInstallation @params
            }
            'List installations on an Organization' {
                $params += @{
                    Organization = $Organization
                }
                Get-GitHubOrganizationAppInstallation @params
            }
            'List installations for the authenticated app' {
                Get-GitHubAppInstallationForAuthenticatedApp @params
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
