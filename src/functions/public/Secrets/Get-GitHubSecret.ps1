function Get-GitHubSecret {
    <#
        .SYNOPSIS
        Retrieve GitHub secret(s) without revealing encrypted value(s).

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
        GitHubSecret[]

        .LINK
        https://psmodule.io/GitHub/Functions/Secrets/Get-GitHubSecret/
    #>
    [OutputType([GitHubSecret[]])]
    [CmdletBinding(DefaultParameterSetName = 'AuthorizedUser')]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Organization', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The name of the environment.
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Environment,

        # The name of the secret.
        [Parameter()]
        [SupportsWildcards()]
        [string] $Name = '*',

        # # The type of secret to retrieve.
        # # Can be either 'actions', 'codespaces'.
        # [Parameter()]
        # [ValidateSet('actions', 'codespaces')]
        # [string] $Type = 'actions',

        # List all secrets that are inherited.
        [Parameter()]
        [switch] $IncludeInherited,

        # List all secrets, including those that are overwritten by inheritance.
        [Parameter()]
        [switch] $All,

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
        $secrets = @()
        $params = @{
            Context = $Context
            Owner   = $Owner
        }

        switch ($PSCmdlet.ParameterSetName) {
            'Organization' {
                if ($Name.Contains('*')) {
                    $secrets += Get-GitHubSecretOwnerList @params |
                        Where-Object { $_.Name -like $Name }
                } else {
                    try {
                        $secrets += Get-GitHubSecretOwnerByName @params -Name $Name
                    } catch { $null }
                }
                break
            }
            'Repository' {
                $params['Repository'] = $Repository
                if ($IncludeInherited) {
                    $secrets += Get-GitHubSecretFromOrganization @params |
                        Where-Object { $_.Name -like $Name }
                }
                if ($Name.Contains('*')) {
                    $secrets += Get-GitHubSecretRepositoryList @params |
                        Where-Object { $_.Name -like $Name }
                } else {
                    try {
                        $secrets += Get-GitHubSecretRepositoryByName @params -Name $Name
                    } catch { $null }
                }
                break
            }
            'Environment' {
                $params['Repository'] = $Repository
                if ($IncludeInherited) {
                    $secrets += Get-GitHubSecretFromOrganization @params |
                        Where-Object { $_.Name -like $Name }
                    if ($Name.Contains('*')) {
                        $secrets += Get-GitHubSecretRepositoryList @params |
                            Where-Object { $_.Name -like $Name }
                    } else {
                        try {
                            $secrets += Get-GitHubSecretRepositoryByName @params -Name $Name
                        } catch { $null }
                    }
                }
                $params['Environment'] = $Environment
                if ($Name.Contains('*')) {
                    $secrets += Get-GitHubSecretEnvironmentList @params |
                        Where-Object { $_.Name -like $Name }
                } else {
                    try {
                        $secrets += Get-GitHubSecretEnvironmentByName @params -Name $Name
                    } catch { $null }
                }
                break
            }
        }
        if ($IncludeInherited -and -not $All) {
            $secrets = $secrets | Group-Object -Property Name | ForEach-Object {
                $group = $_.Group
                $envSecret = $group | Where-Object { $_.Environment }
                if ($envSecret) {
                    $envSecret
                } else {
                    $repoSecret = $group | Where-Object { $_.Repository -and (-not $_.Environment) }
                    if ($repoSecret) {
                        $repoSecret
                    } else {
                        $group | Where-Object { (-not $_.Repository) -and (-not $_.Environment) }
                    }
                }
            }
        }
        $secrets | ForEach-Object { Write-Output $_ }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
