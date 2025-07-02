function Get-GitHubVariable {
    <#
        .SYNOPSIS
        Retrieves a variable from GitHub based on the specified scope.

        .DESCRIPTION
        Gets a variable from GitHub, which can be at the organization, repository, or environment level.
        This function determines the appropriate API call based on the provided parameters.
        Authenticated users must have the required access rights to read variables.
        OAuth tokens and personal access tokens (classic) need the `repo` scope for repositories,
        `admin:org` for organizations, and collaborator access for environments.

        .EXAMPLE
        Get-GitHubVariable -Owner 'octocat' -Name 'HOST_NAME'

        Output:
        ```powershell
        Name        : HOST_NAME
        Value       : github.com
        Owner       : octocat
        Repository  :
        Environment :
        ```

        Retrieves the specified variable from the organization level.

        .EXAMPLE
        Get-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Name 'GUID'

        Output:
        ```powershell
        Name        : GUID
        Value       : 354aa0b0-65b1-46c8-9c3e-1576f4167a41
        Owner       : octocat
        Repository  : Hello-World
        Environment :
        ```

        Retrieves the specified variable from the repository level.

        .EXAMPLE
        Get-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Environment 'dev' -Name 'DB_SERVER'

        Output:
        ```powershell
        Name        : DB_SERVER
        Value       : db.example.com
        Owner       : octocat
        Repository  : Hello-World
        Environment : dev
        ```

        Retrieves the specified variable from the environment level within a repository.

        .EXAMPLE
        Get-GitHubVariable -Owner 'octocat'

        Output:
        ```powershell
        Name        : MAX_THREADS
        Value       : 10
        Owner       : octocat
        Repository  :
        Environment :

        Name        : API_TIMEOUT
        Value       : 30
        Owner       : octocat
        Repository  :
        Environment :
        ```

        Retrieves all variables available at the organization level.

        .EXAMPLE
        Get-GitHubVariable -Owner 'octocat' -Repository 'Hello-World'

        Output:
        ```powershell
        Name        : LOG_LEVEL
        Value       : INFO
        Owner       : octocat
        Repository  : Hello-World
        Environment :

        Name        : FEATURE_FLAG
        Value       : Enabled
        Owner       : octocat
        Repository  : Hello-World
        Environment :
        ```

        Retrieves all variables available at the repository level.

        .EXAMPLE
        Get-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Environment 'staging'

        Output:
        ```powershell
        Name        : CACHE_DURATION
        Value       : 3600
        Owner       : octocat
        Repository  : Hello-World
        Environment : staging

        Name        : CONNECTION_RETRIES
        Value       : 5
        Owner       : octocat
        Repository  : Hello-World
        Environment : staging
        ```

        Retrieves all variables available in the 'staging' environment within the repository.

        .OUTPUTS
        GitHubVariable[]

        .NOTES
        An object or array of objects representing the GitHub variable, containing Name, Value, Owner,
        Repository, and Environment details.

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/Get-GitHubVariable
    #>
    [OutputType([GitHubVariable[]])]
    [CmdletBinding()]
    param(
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

        # The name of the variable.
        [Parameter()]
        [SupportsWildcards()]
        [string] $Name = '*',

        # List all variables that are inherited.
        [Parameter()]
        [switch] $IncludeInherited,

        # List all variables, including those that are overwritten by inheritance.
        [Parameter()]
        [switch] $All,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $variables = @()
        $params = @{
            Context = $Context
            Owner   = $Owner
        }
        switch ($PSCmdlet.ParameterSetName) {
            'Organization' {
                if ($Name.Contains('*')) {
                    $variables += Get-GitHubVariableOwnerList @params |
                        Where-Object { $_.Name -like $Name }
                } else {
                    try {
                        $variables += Get-GitHubVariableOwnerByName @params -Name $Name
                    } catch { $null }
                }
                break
            }
            'Repository' {
                $params['Repository'] = $Repository
                if ($IncludeInherited) {
                    $variables += Get-GitHubVariableFromOrganization @params |
                        Where-Object { $_.Name -like $Name }
                }
                if ($Name.Contains('*')) {
                    $variables += Get-GitHubVariableRepositoryList @params |
                        Where-Object { $_.Name -like $Name }
                } else {
                    try {
                        $variables += Get-GitHubVariableRepositoryByName @params -Name $Name
                    } catch { $null }
                }
                break
            }
            'Environment' {
                $params['Repository'] = $Repository
                if ($IncludeInherited) {
                    $variables += Get-GitHubVariableFromOrganization @params |
                        Where-Object { $_.Name -like $Name }
                    if ($Name.Contains('*')) {
                        $variables += Get-GitHubVariableRepositoryList @params |
                            Where-Object { $_.Name -like $Name }
                    } else {
                        try {
                            $variables += Get-GitHubVariableRepositoryByName @params -Name $Name
                        } catch { $null }
                    }
                }
                $params['Environment'] = $Environment
                if ($Name.Contains('*')) {
                    $variables += Get-GitHubVariableEnvironmentList @params |
                        Where-Object { $_.Name -like $Name }
                } else {
                    try {
                        $variables += Get-GitHubVariableEnvironmentByName @params -Name $Name
                    } catch { $null }
                }
                break
            }
        }

        if ($IncludeInherited -and -not $All) {
            $variables = $variables | Group-Object -Property Name | ForEach-Object {
                $group = $_.Group
                $envVar = $group | Where-Object { $_.Environment }
                if ($envVar) {
                    $envVar
                } else {
                    $repoVar = $group | Where-Object { $_.Repository -and (-not $_.Environment) }
                    if ($repoVar) {
                        $repoVar
                    } else {
                        $group | Where-Object { (-not $_.Repository) -and (-not $_.Environment) }
                    }
                }
            }
        }

        $variables
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
