function Install-GitHubApp {
    <#
        .SYNOPSIS
        Install an app

        .DESCRIPTION
        Installs the provided GitHub App on the specified target.

        .EXAMPLE
        Install-GitHubApp -Enterprise 'msx' -Organization 'org' -ClientID '123456'

        Install the GitHub App with
        - the client ID '123456'
        - the repository selection 'all'
        on the organization 'org' in the enterprise 'msx'.

        .EXAMPLE
        Install-GitHubApp -Enterprise 'msx' -Organization 'org' -ClientID '123456' -Repositories 'repo1', 'repo2'

        Install the GitHub App with
        - the client ID '123456'
        - the repository selection 'selected'
        - the repositories 'repo1' and 'repo2'
        on the organization 'org' in the enterprise 'msx'.

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App/Install-GitHubApp
    #>
    [CmdletBinding()]
    param(
        # The enterprise slug or ID.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Enterprise,

        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Organization,

        # The client ID of the GitHub App to install.
        [Parameter(Mandatory)]
        [string] $ClientID,

        # The names of the repositories to which the installation will be granted access.
        [Parameter()]
        [string[]] $Repositories = @(),

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, UAT
        #enterprise_organization_installations=write
    }

    process {
        $params = @{
            Enterprise   = $Enterprise
            Organization = $Organization
            ClientID     = $ClientID
            Selection    = $Repository.Count -gt 0 ? 'selected' : 'all'
            Repositories = $Repositories
            Context      = $Context
        }
        Install-GitHubAppOnEnterpriseOrganization @params
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
