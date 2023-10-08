filter Get-GitHubRepository {
    <#
    .SYNOPSIS
    Gets a specific repository or list of repositories.

    .DESCRIPTION
    Gets a specific repository or list of repositories based on parameter sets.
    If no parameters are specified, the authenticated user's repositories are returned.
    If a Username parameter is specified, the specified user's public repositories are returned.
    If the SinceId parameter is specified, the repositories with an ID greater than the specified ID are returned.
    If an Owner and Repo parameters are specified, the specified repository is returned.
    If the Owner and Repo parameters are specified, the specified repository is returned.

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [CmdletBinding(DefaultParameterSetName = 'MyRepos_Type')]
    param (
        #Limit results to repositories with the specified visibility.
        [Parameter(ParameterSetName = 'MyRepos_Aff-Vis')]
        [validateSet('all', 'public', 'private')]
        [string] $Visibility = 'all',

        # Comma-separated list of values. Can include:
        # - owner: Repositories that are owned by the authenticated user.
        # - collaborator: Repositories that the user has been added to as a collaborator.
        # - organization_member: Repositories that the user has access to through being a member of an organization. This includes every repository on every team that the user is on.
        # Default: owner, collaborator, organization_member
        [Parameter(ParameterSetName = 'MyRepos_Aff-Vis')]
        [validateset('owner', 'collaborator', 'organization_member')]
        [string[]] $Affiliation = @('owner', 'collaborator', 'organization_member'),

        # A repository ID. Only return repositories with an ID greater than this ID.
        [Parameter(ParameterSetName = 'ListByID')]
        [int] $SinceID = 0,

        # Only show repositories updated after the given time.
        [Parameter(ParameterSetName = 'MyRepos_Type')]
        [Parameter(ParameterSetName = 'MyRepos_Aff-Vis')]
        [datetime] $Since,

        # Only show repositories updated before the given time.
        [Parameter(ParameterSetName = 'MyRepos_Type')]
        [Parameter(ParameterSetName = 'MyRepos_Aff-Vis')]
        [datetime] $Before,

        # The account owner of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(ParameterSetName = 'ListByOrg')]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ListByUser'
        )]
        [Alias('login')]
        [string] $Username,

        # Specifies the types of repositories you want returned.
        [Parameter(ParameterSetName = 'MyRepos_Type')]
        [Parameter(ParameterSetName = 'ListByOrg')]
        [Parameter(ParameterSetName = 'ListByUser')]
        [validateSet('all', 'public', 'private', 'forks', 'sources', 'member')]
        [string] $Type = 'all',

        # The property to sort the results by.
        [Parameter(ParameterSetName = 'MyRepos_Type')]
        [Parameter(ParameterSetName = 'MyRepos_Aff-Vis')]
        [Parameter(ParameterSetName = 'ListByOrg')]
        [Parameter(ParameterSetName = 'ListByUser')]
        [validateSet('created', 'updated', 'pushed', 'full_name')]
        [string] $Sort = 'created',

        # The order to sort by.
        # Default: asc when using full_name, otherwise desc.
        [Parameter(ParameterSetName = 'MyRepos')]
        [Parameter(ParameterSetName = 'ListByOrg')]
        [Parameter(ParameterSetName = 'ListByUser')]
        [validateSet('asc', 'desc')]
        [string] $Direction,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'MyRepos')]
        [Parameter(ParameterSetName = 'ListByOrg')]
        [Parameter(ParameterSetName = 'ListByUser')]
        [int] $PerPage = 30

    )

    switch ($PSCmdlet.ParameterSetName) {
        'MyRepos_Type' {
            $params = @{
                Type      = $Type
                Sort      = $Sort
                Direction = $Direction
                PerPage   = $PerPage
                Since     = $Since
                Before    = $Before
            }
            Get-GitHubMyRepositories @params
        }
        'MyRepos_Aff-Vis' {
            $params = @{
                Visibility  = $Visibility
                Affiliation = $Affiliation
                Sort        = $Sort
                Direction   = $Direction
                PerPage     = $PerPage
                Since       = $Since
                Before      = $Before
            }
            Get-GitHubMyRepositories @params
        }
        'ByName' {
            $params = @{
                Owner = $Owner
                Repo  = $Repo
            }
            Get-GitHubRepositoryByName @params
        }
        'ListByID' {
            $params = @{
                Since = $SinceID
            }
            Get-GitHubRepositoryListByID @params
        }
        'ListByOrg' {
            $params = @{
                Owner     = $Owner
                Type      = $Type
                Sort      = $Sort
                Direction = $Direction
                PerPage   = $PerPage
            }
            Get-GitHubRepositoryListByOrg @params
        }
        'ListByUser' {
            $params = @{
                Username  = $Username
                Type      = $Type
                Sort      = $Sort
                Direction = $Direction
                PerPage   = $PerPage
            }
            Get-GitHubRepositoryListByUser @params
        }
    }

}
