function Get-GitHubAppInstallation {
    <#
        .SYNOPSIS
        List installations for the authenticated app, on organization or enterprise organization, or get a single installation by ID.

        .DESCRIPTION
        Lists the installations for the authenticated app.
        If the app is installed on an enterprise, the installations for the enterprise are returned.
        If the app is installed on an organization, the installations for the organization are returned.
        You can also retrieve a single installation by its unique ID.

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
            ParameterSetName = 'List installations on an Enterprise Organization'
        )]
        [string] $Enterprise,

        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'List installations on an Enterprise Organization'
        )]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'List installations on an Organization'
        )]
        [string] $Organization,

        # The unique identifier of the installation.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Get installation for the authenticated app by ID'
        )]
        [int] $ID,

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
        Write-Debug "ParamSet: $($PSCmdlet.ParameterSetName)"
        $installations = switch ($PSCmdlet.ParameterSetName) {
            'List installations on an Enterprise Organization' {
                $params += @{
                    Enterprise   = $Enterprise
                    Organization = $Organization
                }
                Get-GitHubAppInstallationForEnterpriseOrganization @params
            }
            'List installations on an Organization' {
                $params += @{
                    Organization = $Organization
                }
                Get-GitHubAppInstallationForOrganization @params
            }
            'Get installation for the authenticated app by ID' {
                Get-GitHubAppInstallationForAuthenticatedAppByID -ID $ID -Context $Context
            }
            'List installations for the authenticated app' {
                Get-GitHubAppInstallationForAuthenticatedAppAsList @params
            }
        }
    }

    end {
        $installations | Sort-Object -Property Type, Target
        Write-Debug "[$stackPath] - End"
    }
}
