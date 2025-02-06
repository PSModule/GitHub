function Get-GitHubSecret {
    <#
        .SYNOPSIS
        Retrieve GitHub Secret(s) without revealing encrypted value(s).

        .DESCRIPTION
        Retrieves GitHub secrets from a repository, organization, or environment without exposing
        the actual secret values. Supports multiple contexts such as Actions, Codespaces, and
        Organization secrets.

        The function returns an array of PSObjects containing metadata about the secrets.

        .EXAMPLE
        Get-GitHubSecret -Owner PSModule -Repo Demo -Type actions

        Retrieves all Actions secrets from the 'Demo' repository under the 'PSModule' organization.

        .EXAMPLE
        Get-GitHubSecret -Owner PSModule -Type organization

        Retrieves all organization-level secrets under the 'PSModule' organization.

        .EXAMPLE
        Get-GitHubSecret -Owner PSModule -Repo Demo -Environment Staging

        Retrieves all secrets for the 'Staging' environment in the 'Demo' repository under 'PSModule'.

        .OUTPUTS
        [PSObject[]]

        .LINK
        https://psmodule.io/GitHub/Functions/Secrets/Get-GitHubSecret/
    #>
    [OutputType([psobject[]])]
    [CmdletBinding(DefaultParameterSetName = 'AuthorizedUser', SupportsPaging)]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Environment')]
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string] $Repository,

        # The name of the repository environment.
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [string] $Environment,

        # The name of the secret.
        [Parameter()]
        [string] $Name,

        # The type of secret to retrieve.
        # Can be either 'actions', 'codespaces', or 'organization'.
        [Parameter()]
        [ValidateSet('actions', 'codespaces', 'organization')]
        [string] $Type = 'actions',

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        # $Context = Resolve-GitHubContext -Context $Context
        # Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = switch ($PSCmdlet.ParameterSetName) {
                'Environment' {
                    "/repos/$Owner/$Repository/environments/$Environment/secrets"
                    break
                }
                'Organization' {
                    "/orgs/$Owner/$Type/secrets"
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
            Context     = $Context
        }

        # There is no endpoint for /repos/$Owner/$Repository/actions/organization-secrets/$Name
        if ($Type -ne 'organization' -and -not [string]::IsNullOrWhiteSpace($Name)) {
            $inputObject.APIEndpoint += "/$Name"
        }

        $response = Invoke-GitHubAPI @inputObject | Select-Object -ExpandProperty Response
        [bool]$response.PSObject.Properties['secrets'] ? $response.secrets : $response
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
