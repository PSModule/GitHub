function Remove-GitHubSecret {
    <#
    .SYNOPSIS
        Delete a secret.

    .PARAMETER Organization
        The organization name. The name is not case sensitive.

    .PARAMETER Owner
        The account owner of the repository. The name is not case sensitive.

    .PARAMETER Repository
        The name of the repository. The name is not case sensitive.

    .PARAMETER Environment
        The name of the repository environment.

    .PARAMETER Name
        The name of the secret.

    .PARAMETER Type
        actions / codespaces

    .EXAMPLE
        > Remove-GitHubSecret -Owner PSModule -Repository Demo -Type actions -Name TEST

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#delete-an-organization-secret

    .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#delete-a-repository-secret

    .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#delete-an-environment-secret

    .LINK
        https://docs.github.com/en/rest/codespaces/secrets?apiVersion=2022-11-28#delete-a-secret-for-the-authenticated-user
    #>
    [CmdletBinding(DefaultParameterSetName = 'AuthenticatedUser', SupportsShouldProcess)]
    param (
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [string]$Organization,

        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string]$Owner,

        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string]$Repository,

        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [string]$Environment,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Name,

        [ValidateSet('actions', 'codespaces')]
        [string]$Type = 'actions',

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object]$Context = (Get-GitHubContext)
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

        if ([string]::IsNullOrEmpty($Repository)) {
            $Repository = $Context.Repo
        }
        Write-Debug "Repository: [$Repository]"
    }

    process {
        $delParams = @{
            APIEndpoint = switch ($PSCmdlet.ParameterSetName) {
                'Environment' {
                    "/repos/$Owner/$Repository/environments/$Environment/secrets/$Name"
                    break
                }
                'Organization' {
                    "/orgs/$Organization/$Type/secrets/$Name"
                    break
                }
                'Repository' {
                    "/repos/$Owner/$Repository/$Type/secrets/$Name"
                    break
                }
                'AuthenticatedUser' {
                    "/user/codespaces/secrets/$Name"
                    break
                }
            }
            Context     = $Context
            Method      = 'DELETE'
        }
        if ($PSCmdLet.ShouldProcess(
                "Deleting GitHub $Type secret [$Name]",
                "Are you sure you want to delete $($($delParams.APIEndPoint))?",
                'Delete secret'
            )) {
            Invoke-GitHubAPI @delParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
