function Uninstall-GitHubAppOnEnterpriseOrganization {
    <#
        .SYNOPSIS
        Uninstall a GitHub App from an organization.

        .DESCRIPTION
        Uninstall a GitHub App from an organization.

        The authenticated GitHub App must be installed on the enterprise and be granted the Enterprise/organization_installations (write) permission.

        .EXAMPLE
        Uninstall-GitHubAppOnEnterpriseOrganization -Enterprise 'github' -Organization 'octokit' -InstallationID '123456'

        Uninstall the GitHub App with the installation ID '123456' from the organization 'octokit' in the enterprise 'github'.
    #>
    #SkipTest:FunctionTest:Will add a test for this function in a future PR
    [CmdletBinding()]
    param(
        # The enterprise slug or ID.
        [Parameter()]
        [string] $Enterprise,

        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Organization,

        # The client ID of the GitHub App to install.
        [Parameter(Mandatory)]
        [Alias('installation_id')]
        [string] $InstallationID,

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
                APIEndpoint = "/enterprises/$Enterprise/apps/organizations/$Organization/installations/$InstallationID}"
                Method      = 'Delete'
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
