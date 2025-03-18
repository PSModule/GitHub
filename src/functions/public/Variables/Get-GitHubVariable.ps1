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
        Get-GitHubVariable -Owner 'octocat' -Name 'HOST_NAME' -Context $GitHubContext

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
        Get-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Name 'GUID' -Context $GitHubContext

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
        Get-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Environment 'dev' -Name 'DB_SERVER' -Context $GitHubContext

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
        Get-GitHubVariable -Owner 'octocat' -Context $GitHubContext

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
        Get-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Context $GitHubContext

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
        Get-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Environment 'staging' -Context $GitHubContext

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
        GitHubVariable

        .NOTES
        An object representing the GitHub variable, containing Name, Value, Owner,
        Repository, and Environment details.

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/Get-GitHubVariable
    #>
    [OutputType([GitHubVariable])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Organization')]
        [Parameter(Mandatory, ParameterSetName = 'Repository')]
        [Parameter(Mandatory, ParameterSetName = 'Environment')]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Repository')]
        [Parameter(Mandatory, ParameterSetName = 'Environment')]
        [string] $Repository,

        # The name of the environment.
        [Parameter(Mandatory, ParameterSetName = 'Environment')]
        [string] $Environment,

        # The name of the variable.
        [Parameter()]
        [SupportsWildcards()]
        [string] $Name = '*',

        # List all variables that are inherited.
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
        $variables = @()
        switch ($PSCmdlet.ParameterSetName) {
            'Organization' {
                $variables += Get-GitHubVariableOwnerList -Owner $Owner -Context $Context
                break
            }
            'Repository' {
                if ($All) {
                    $variables += Get-GitHubVariableFromOrganization -Owner $Owner -Repository $Repository -Context $Context
                }
                $variables += Get-GitHubVariableRepositoryList -Owner $Owner -Repository $Repository -Context $Context
                break
            }
            'Environment' {
                if ($All) {
                    $variables += Get-GitHubVariableFromOrganization -Owner $Owner -Repository $Repository -Context $Context
                    $variables += Get-GitHubVariableRepositoryList -Owner $Owner -Repository $Repository -Context $Context
                }
                $variables += Get-GitHubVariableEnvironmentList -Owner $Owner -Repository $Repository -Environment $Environment -Context $Context
                break
            }
        }
        $variables | Where-Object { $_.Name -like $Name }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
