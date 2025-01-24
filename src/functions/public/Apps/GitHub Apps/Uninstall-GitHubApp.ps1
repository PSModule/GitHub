function Uninstall-GitHubApp {
    <#
        .SYNOPSIS
        Uninstall a GitHub App.

        .DESCRIPTION
        Uninstalls the provided GitHub App on the specified target.

        .EXAMPLE
        Uninstall-GitHubApp -Enterprise 'msx' -Organization 'org' -InstallationID '123456'

        Uninstall the GitHub App with the installation ID '123456' from the organization 'org' in the enterprise 'msx'.
    #>
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        # The enterprise slug or ID.
        [Parameter(
            Mandatory,
            ParameterSetName = 'EnterpriseOrganization',
            ValueFromPipelineByPropertyName
        )]
        [string] $Enterprise,

        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ParameterSetName = 'EnterpriseOrganization',
            ValueFromPipelineByPropertyName
        )]
        [string] $Organization,

        # The client ID of the GitHub App to install.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('installation_id', 'id')]
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
    }

    process {
        if ([string]::IsNullOrEmpty($Enterprise)) {
            $Enterprise = $Context.Enterprise
        }
        Write-Debug "Enterprise: [$Enterprise]"
        if ([string]::IsNullOrEmpty($Organization)) {
            $Organization = $Context.Organization
        }
        Write-Debug "Organization: [$Organization]"
        try {
            switch ($PSCmdlet.ParameterSetName) {
                'EnterpriseOrganization' {
                    $params = @{
                        Enterprise     = $Enterprise
                        Organization   = $Organization
                        InstallationID = $InstallationID
                        Context        = $Context
                    }
                    Uninstall-GitHubAppOnEnterpriseOrganization @params
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
