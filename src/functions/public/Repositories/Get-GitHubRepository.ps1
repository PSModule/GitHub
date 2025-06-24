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

        .EXAMPLE
        Get-GitHubRepository -Organization 'github' -Team 'my-team'

        Gets repositories that the 'my-team' team has access to in the 'github' organization.

        .EXAMPLE
        Get-GitHubRepository -Organization 'github' -Name 'octocat' -Team 'my-team'

        Gets the repository and permission for the 'my-team' team on the 'octocat' repository in the 'github' organization.

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
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Get a repository by name')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'List repositories from an account')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Get the repository and permission for the specified team')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'List repositories for a team')]
        [Alias('Organization', 'Username')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Get a repository by name')]
        [Parameter(Mandatory, ParameterSetName = 'Get a repository for the authenticated user by name')]
        [Parameter(Mandatory, ParameterSetName = 'Get the repository and permission for the specified team')]
        [string] $Name,

        # The slug of the team.
        [Parameter(Mandatory, ParameterSetName = 'Get the repository and permission for the specified team')]
        [Parameter(Mandatory, ParameterSetName = 'List repositories for a team')]
        [string] $Team,

        # Limit the results to repositories with a visibility level.
        [Parameter(ParameterSetName = 'List repositories for the authenticated user')]
        [Parameter(ParameterSetName = 'List repositories from an account')]
        [ValidateSet('Internal', 'Private', 'Public')]
        [string] $Visibility,

        # Limit the results to repositories where the user has this role.
        [Parameter(ParameterSetName = 'List repositories for the authenticated user')]
        [Parameter(ParameterSetName = 'List repositories from an account')]
        [ValidateSet('Owner', 'Collaborator', 'Organization_member')]
        [string[]] $Affiliation,

        # Properties to include in the returned object.
        [Parameter()]
        [string[]] $Property,

        # Additional properties to include in the returned object. Is added to the list of properties to include.
        # This is useful for properties that are not included in the default list of properties.
        [Parameter()]
        [string[]] $AdditionalProperty,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'List repositories for the authenticated user')]
        [Parameter(ParameterSetName = 'List repositories from an account')]
        [System.Nullable[int]] $PerPage,

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
        $params = @{
            Context            = $Context
            Owner              = $Owner
            Name               = $Name
            Team               = $Team
            Affiliation        = $Affiliation
            Visibility         = $Visibility
            PerPage            = $PerPage
            Property           = $Property
            AdditionalProperty = $AdditionalProperty
        }
        $params | Remove-HashtableEntry -NullOrEmptyValues
        if ($DebugPreference -eq 'Continue') {
            Write-Debug "ParamSet: [$($PSCmdlet.ParameterSetName)]"
            [pscustomobject]$params | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        }
        switch ($PSCmdlet.ParameterSetName) {
            'Get a repository for the authenticated user by name' {
                try {
                    Get-GitHubMyRepositoryByName @params
                } catch { return }
            }
            'List repositories for the authenticated user' {
                Get-GitHubMyRepositories @params
            }
            'Get a repository by name' {
                try {
                    Get-GitHubRepositoryByName @params
                } catch { return }
            }
            'List repositories from an account' {
                Get-GitHubRepositoryListByOwner @params
            }
            'List repositories for a team' {
                try {
                    Get-GitHubRepositoryListByTeam @params
                } catch { return }
            }
            'Get the repository and permission for the specified team' {
                try {
                    Get-GitHubRepositoryByNameAndTeam @params
                } catch { return }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
