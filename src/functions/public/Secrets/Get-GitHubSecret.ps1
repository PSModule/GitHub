function Get-GitHubSecret {
    <#
    .SYNOPSIS
        Retrieve GitHub Secret(s) without revealing encrypted value(s).

    .PARAMETER Organization
        The organization name. The name is not case sensitive.

    .PARAMETER Owner
        The account owner of the repository. The name is not case sensitive.

    .PARAMETER Repository
        The name of the repository. The name is not case sensitive.

    .PARAMETER Environment
        The name of the repository environment.

    .PARAMETER Type
        actions / codespaces / organization

        organization lists all organization actions secrets shared with a repository

    .PARAMETER Name
        The name of the secret.

    .EXAMPLE
        > Get-GitHubSecret -Owner PSModule -Repo Demo -Type actions

        name         : AZDO_ACCESS_TOKEN
        display_name :
        location     :
        state        :
        created_at   : 1/14/2025 1:17:32 AM
        updated_at   : 1/14/2025 1:17:32 AM
        last_used_at :

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#list-repository-secrets

    .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#list-organization-secrets

    .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#list-environment-secrets

    .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#get-a-repository-secret

    .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#get-an-organization-secret

    .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#get-an-environment-secret

    .LINK
        https://docs.github.com/en/rest/codespaces/secrets?apiVersion=2022-11-28#list-secrets-for-the-authenticated-user

    .LINK
        https://docs.github.com/en/rest/codespaces/secrets?apiVersion=2022-11-28#get-a-secret-for-the-authenticated-user

    .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#list-repository-organization-secrets

    #>
    [CmdletBinding(DefaultParameterSetName = 'AuthorizedUser', SupportsPaging)]
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

        [string]$Name,

        [ValidateSet('actions', 'codespaces', 'organization')]
        [string]$Type = 'actions',

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
            $Repository = $Context.Repo
        }
        Write-Debug "Repository: [$Repository]"
    }

    process {
        $getParams = @{
            APIEndpoint    = switch ($PSCmdlet.ParameterSetName) {
                'Environment' {
                    "/repos/$Owner/$Repository/environments/$Environment/secrets"
                    break
                }
                'Organization' {
                    "/orgs/$Organization/$Type/secrets"
                    break
                }
                'Repository' {
                    $Type -eq 'organization' ?
                        "/repos/$Owner/$Repository/actions/organization-secrets" :
                        "/repos/$Owner/$Repository/$Type/secrets"
                    break
                }
                'AuthorizedUser' {
                    'user/codespaces/secrets'
                }
            }
            Context        = $Context
            Method         = 'GET'
        }
        # There is no endpoint for /repos/$Owner/$Repository/actions/organization-secrets/$Name
        if ($Type -ne 'organization'-and -not [string]::IsNullOrWhiteSpace($Name)) {
            $getParams.APIEndpoint += "/$Name"
        }
        $response = Invoke-GitHubAPI @getParams | Select-Object -ExpandProperty Response
        [bool]$response.PSObject.Properties['secrets'] ? $response.secrets : $response
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
