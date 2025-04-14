#Requires -Modules @{ ModuleName = 'DynamicParams'; RequiredVersion = '1.1.8' }

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

        Gets the  authenticated user's repositories.

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
    [CmdletBinding(DefaultParameterSetName = 'MyRepos')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'ByName', ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'ListByOrg', ValueFromPipelineByPropertyName)]
        [string] $Organization,

        # The handle for the GitHub user account.
        [Parameter(ParameterSetName = 'ByName', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'ListByUser', ValueFromPipelineByPropertyName)]
        [Alias('User')]
        [string] $Username,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string] $Name,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'MyRepos')]
        [Parameter(ParameterSetName = 'ListByOrg')]
        [Parameter(ParameterSetName = 'ListByUser')]
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
            'MyRepos' {
                $params = @{
                    Context = $Context
                    PerPage = $PerPage
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                Write-Verbose ($params | Format-List | Out-String)
                Get-GitHubMyRepositories @params
            }
            'ByName' {
                $owner = if ($PSBoundParameters.ContainsKey('Username')) {
                    $Username
                } elseif ($PSBoundParameters.ContainsKey('Organization')) {
                    $Organization
                } else {
                    (Get-GitHubUser -Context $Context).Name
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
            'ListByOrg' {
                $params = @{
                    Context      = $Context
                    Organization = $Organization
                    PerPage      = $PerPage
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                Write-Verbose ($params | Format-List | Out-String)
                Get-GitHubRepositoryListByOrg @params
            }
            'ListByUser' {
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
