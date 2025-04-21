filter Get-GitHubRepository {
    <#
        .SYNOPSIS
        Gets a specific repository or list of repositories.

        .DESCRIPTION
        Gets a specific repository or list of repositories.
        If no parameters are specified, the authenticated user's repositories are returned.
        If a username is specified, the user's public repositories are returned.
        If an organization is specified, the organization's public repositories are returned.
        Can also be used with the name parameter to get a specific repository.

        .EXAMPLE
        Get-GitHubRepository

        Gets the repositories for the authenticated user.

        .EXAMPLE
        Get-GitHubRepository -Type all

        Gets the repositories owned by the authenticated user.

        .EXAMPLE
        Get-GitHubRepository -Username 'octocat'

        Gets the repositories for the specified user.

        .EXAMPLE
        Get-GitHubRepository -Owner 'github' -Name 'octocat'

        Gets the specified repository.

        .INPUTS
        GitHubOwner

        .OUTPUTS
        GithubRepository

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Get-GitHubRepository/
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding(DefaultParameterSetName = 'List repositories for the authenticated user by type')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Get a repository by name', ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'List organization repositories', ValueFromPipelineByPropertyName)]
        [string] $Organization,

        # The handle for the GitHub user account.
        [Parameter(ParameterSetName = 'Get a repository by name', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'List user repositories', ValueFromPipelineByPropertyName)]
        [Alias('User')]
        [string] $Username,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Get a repository by name')]
        [string] $Name,

        # Specifies the types of repositories you want returned.
        [Parameter(ParameterSetName = 'List repositories for the authenticated user by type')]
        [string] $Type,

        # Limit results to repositories with the specified visibility.
        [Parameter(ParameterSetName = 'List repositories for the authenticated user by affiliation and visibility')]
        [ValidateSet('all', 'public', 'private')]
        [string] $Visibility = 'all',

        # Comma-separated list of values. Can include:
        # - owner: Repositories that are owned by the authenticated user.
        # - collaborator: Repositories that the user has been added to as a collaborator.
        # - organization_member: Repositories that the user has access to through being a member of an organization.
        #   This includes every repository on every team that the user is on.
        [Parameter(ParameterSetName = 'List repositories for the authenticated user by affiliation and visibility')]
        [ValidateSet('owner', 'collaborator', 'organization_member')]
        [string[]] $Affiliation = 'owner',

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'List repositories for the authenticated user by type')]
        [Parameter(ParameterSetName = 'List organization repositories')]
        [Parameter(ParameterSetName = 'List user repositories')]
        [ValidateRange(0, 100)]
        [int] $PerPage,

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
        Write-Debug "ParamSet: [$($PSCmdlet.ParameterSetName)]"
        switch ($PSCmdlet.ParameterSetName) {
            'List repositories for the authenticated user by type' {
                $params = @{
                    Context = $Context
                    PerPage = $PerPage
                }
                $params['Affiliation'] = $Affiliation
                $params['Visibility'] = $Visibility
                $params['Type'] = $Type
                Write-Verbose ($params | Format-List | Out-String)
                Get-GitHubMyRepositories @params
            }
            'List repositories for the authenticated user by affiliation and visibility' {
                $params = @{
                    Context     = $Context
                    Affiliation = $Affiliation
                    Visibility  = $Visibility
                    PerPage     = $PerPage
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                Write-Verbose ($params | Format-List | Out-String)
                Get-GitHubMyRepositories @params
            }
            'Get a repository by name' {
                $owner = if ($PSBoundParameters.ContainsKey('Username')) {
                    $Username
                } elseif ($PSBoundParameters.ContainsKey('Organization')) {
                    $Organization
                } else {
                    $Context.UserName
                }
                $params = @{
                    Context = $Context
                    Owner   = $owner
                    Name    = $Name
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                Write-Verbose ($params | Format-List | Out-String)
                try {
                    Get-GitHubRepositoryByName @params
                } catch { return }
            }
            'List organization repositories' {
                $params = @{
                    Context      = $Context
                    Organization = $Organization
                    PerPage      = $PerPage
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                Write-Verbose ($params | Format-List | Out-String)
                Get-GitHubRepositoryListByOrg @params
            }
            'List user repositories' {
                $params = @{
                    Context  = $Context
                    Username = $Username
                    PerPage  = $PerPage
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                Write-Verbose ($params | Format-List | Out-String)
                Get-GitHubRepositoryListByUser @params
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

Register-ArgumentCompleter -CommandName Get-GitHubRepository -ParameterName Type -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters

    $validateSet = if ($fakeBoundParameters.ContainsKey('Organization')) {
        'all', 'public', 'private', 'forks', 'sources', 'member'
    } elseif ($fakeBoundParameters.ContainsKey('Username')) {
        'all', 'owner', 'member'
    } else {
        'all', 'owner', 'public', 'private', 'member'
    }

    $validateSet | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
