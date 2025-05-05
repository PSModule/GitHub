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
        Get-GitHubRepository -Username 'octocat'

        Gets the repositories for the specified user.

        .EXAMPLE
        Get-GitHubRepository -Organization 'github' -Name 'octocat'

        Gets the specified repository.

        .INPUTS
        GitHubOwner

        .OUTPUTS
        GithubRepository

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Get-GitHubRepository/
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding(DefaultParameterSetName = 'List repositories for the authenticated user')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Get a repository by name', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'List repositories from an account', ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'Username')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Get a repository by name')]
        [Parameter(Mandatory, ParameterSetName = 'Get a repository for the authenticated user by name')]
        [string] $Name,

        # Limit the results to repositories with a visibility level.
        [Parameter(ParameterSetName = 'List repositories for the authenticated user')]
        [Parameter(ParameterSetName = 'List repositories from an account')]
        [ValidateSet('Internal', 'Private', 'Public')]
        [Parameter()]
        [string] $Visibility,

        # Limit the results to repositories where the user has this role.
        [Parameter(ParameterSetName = 'List repositories for the authenticated user')]
        [Parameter(ParameterSetName = 'List repositories from an account')]
        [ValidateSet('Owner', 'Collaborator', 'Organization_member')]
        [Parameter()]
        [string[]] $Affiliation = 'Owner',

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'List repositories for the authenticated user')]
        [Parameter(ParameterSetName = 'List repositories from an account')]
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
            'Get a repository for the authenticated user by name' {
                $params = @{
                    Context = $Context
                    Name    = $Name
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                Write-Verbose ($params | Format-Table -AutoSize | Out-String)
                Get-GitHubMyRepositoryByName @params
            }
            'List repositories for the authenticated user' {
                $params = @{
                    Context     = $Context
                    Affiliation = $Affiliation
                    Visibility  = $Visibility
                    PerPage     = $PerPage
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                Write-Verbose ($params | Format-Table -AutoSize | Out-String)
                Get-GitHubMyRepositories @params
            }
            'Get a repository by name' {
                $params = @{
                    Context = $Context
                    Owner   = $Owner ?? $Context.UserName
                    Name    = $Name
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                Write-Verbose ($params | Format-Table -AutoSize | Out-String)
                try {
                    Get-GitHubRepositoryByName @params
                } catch { return }
            }
            'List repositories from an account' {
                $params = @{
                    Context     = $Context
                    Owner       = $Owner
                    Affiliation = $Affiliation
                    Visibility  = $Visibility
                    PerPage     = $PerPage
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                Write-Verbose ($params | Format-Table -AutoSize | Out-String)
                Get-GitHubRepositoryListByOwner @params
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
