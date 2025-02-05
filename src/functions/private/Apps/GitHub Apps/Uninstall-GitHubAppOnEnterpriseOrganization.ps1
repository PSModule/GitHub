function Uninstall-GitHubAppOnEnterpriseOrganization {
    <#
        .SYNOPSIS
        Uninstall a GitHub App from an organization.

        .DESCRIPTION
        Uninstall a GitHub App from an organization.

        The authenticated GitHub App must be installed on the enterprise and be granted the Enterprise/organization_installations (write) permission.

        .EXAMPLE
        Uninstall-GitHubAppOnEnterpriseOrganization -Enterprise 'github' -Organization 'octokit' -InstallationID '123456'

        Uninstall the GitHub App with the installation ID `123456` from the organization `octokit` in the enterprise `github`.
    #>
    [CmdletBinding()]
    param(
        # The enterprise slug or ID.
        [Parameter(Mandatory)]
        [string] $Enterprise,

        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Organization,

        # The client ID of the GitHub App to install.
        [Parameter(Mandatory)]
        [string] $ID,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, UAT
        #enterprise_organization_installations=write
    }

    process {
        $inputObject = @{
            Method      = 'DELETE'
            APIEndpoint = "/enterprises/$Enterprise/apps/organizations/$Organization/installations/$ID"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
