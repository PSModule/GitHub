function Add-GitHubAppInstallationRepositoryAccess {
    <#
        .SYNOPSIS
        Grant repository access to an organization installation.

        .DESCRIPTION
        Grant repository access to an organization installation.

        .EXAMPLE
        $params = @{
            Enterprise          = 'msx'
            Organization        = 'PSModule'
            InstallationID      = 12345678
            Repositories        = 'repo1', 'repo2'
        }
        Add-GitHubAppInstallationRepositoryAccess @params

        Grant access to the repositories 'repo1' and 'repo2' for the installation
        with the ID '12345678' on the organization 'PSModule' in the enterprise 'msx'.
    #>
    [CmdletBinding(SupportsShouldProcess)]
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

        # The unique identifier of the installation.
        # Example: '12345678'
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('installation_id', 'InstallationID')]
        [int] $ID,

        # The names of the repositories to which the installation will be granted access.
        [Parameter()]
        [string[]] $Repositories = @(),

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
        Write-Debug "Enterprise : [$($Context.Enterprise)]"

        if ([string]::IsNullOrEmpty($Organization)) {
            $Organization = $Context.Organization
        }
        Write-Debug "Organization : [$($Context.Organization)]"
    }

    process {
        try {
            $body = @{
                repositories = $Repositories
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/enterprises/$Enterprise/apps/organizations/$Organization/installations/$ID/repositories/add"
                Method      = 'PATCH'
                Body        = $body
            }

            if ($PSCmdlet.ShouldProcess('Target', 'Operation')) {
                Invoke-GitHubAPI @inputObject | ForEach-Object {
                    Write-Output $_.Response
                }
            }
        } catch {
            Write-Debug "Error: $_"
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
