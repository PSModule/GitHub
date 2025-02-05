function Get-GitHubPublicKey {
    <#
        .SYNOPSIS
        Gets your public key, which you need to encrypt secrets.

        .DESCRIPTION
        Gets your public key, which you need to encrypt secrets. You need to encrypt a secret before you can create or update secrets.

        .EXAMPLE
        Get-GitHubPublicKey -Owner MyOrg -Repo MyRepo

        key_id              key
        ------              ---
        3780435238020453366 Et862t3cCgJnI8e8D6Z9BUvvtdS7eZdkhdap+bgJAi4=

        .OUTPUTS
        [PSObject[]]

        .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#get-a-repository-public-key

        .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#get-an-organization-public-key

        .LINK
        https://docs.github.com/en/rest/codespaces/organization-secrets?apiVersion=2022-11-28#get-an-organization-public-key

        .LINK
        https://docs.github.com/en/rest/codespaces/secrets?apiVersion=2022-11-28#get-public-key-for-the-authenticated-user
    #>
    [CmdletBinding(DefaultParameterSetName = 'AuthenticatedUser')]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Organization'
        )]
        [string] $Organization,

        # The account owner of the repository. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Repository'
        )]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Repository'
        )]
        [string] $Repository,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter()]
        [ValidateSet('actions', 'codespaces')]
        [string] $Type = 'actions',

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

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner: [$Owner]"

        if ([string]::IsNullOrEmpty($Repository)) {
            $Repository = $Context.Repository
        }
        Write-Debug "Repository: [$Repository]"
    }

    process {
        $getParams = @{
            APIEndpoint = switch ($PSCmdlet.ParameterSetName) {
                'Organization' {
                    "/orgs/$Organization/$Type/secrets/public-key"
                    break
                }
                'Repository' {
                    "/repos/$Owner/$Repository/$Type/secrets/public-key"
                    break
                }
                'AuthenticatedUser' {
                    '/user/codespaces/secrets/public-key'
                    break
                }
            }
            Context     = $Context
            Method      = 'GET'
        }
        Invoke-GitHubAPI @getParams | Select-Object -ExpandProperty Response
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
