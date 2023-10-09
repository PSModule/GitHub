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

        .PARAMETER Type
        Specifies the types of repositories you want returned.

        .EXAMPLE
        Get-GitHubRepository

        Gets the repositories for the authenticated user.

        .EXAMPLE
        Get-GitHubRepository -Type 'owner'

        Gets the repositories owned by the authenticated user.

        .EXAMPLE
        Get-GitHubRepository -Username 'octocat'

        Gets the repositories for the specified user.

        .EXAMPLE
        Get-GitHubRepository -SinceID 123456789

        Gets the repositories with an ID equals and greater than 123456789.

        .EXAMPLE
        Get-GitHubRepository -Owner 'github' -Repo 'octocat'

        Gets the specified repository.

        .NOTES
        https://docs.github.com/rest/repos/repos#list-repositories-for-the-authenticated-user
        https://docs.github.com/rest/repos/repos#get-a-repository
        https://docs.github.com/rest/repos/repos#list-public-repositories
        https://docs.github.com/rest/repos/repos#list-organization-repositories
        https://docs.github.com/rest/repos/repos#list-repositories-for-a-user

    #>
    [CmdletBinding(DefaultParameterSetName = 'MyRepos_Type')]
    param (
        #Limit results to repositories with the specified visibility.
        [Parameter(ParameterSetName = 'MyRepos_Aff-Vis')]
        [ValidateSet('all', 'public', 'private')]
        [string] $Visibility = 'all',

        # Comma-separated list of values. Can include:
        # - owner: Repositories that are owned by the authenticated user.
        # - collaborator: Repositories that the user has been added to as a collaborator.
        # - organization_member: Repositories that the user has access to through being a member of an organization. This includes every repository on every team that the user is on.
        # Default: owner, collaborator, organization_member
        [Parameter(ParameterSetName = 'MyRepos_Aff-Vis')]
        [ValidateSet('owner', 'collaborator', 'organization_member')]
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
        [Parameter(
            Mandatory,
            ParameterSetName = 'ByName'
        )]
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

        # The property to sort the results by.
        [Parameter(ParameterSetName = 'MyRepos_Type')]
        [Parameter(ParameterSetName = 'MyRepos_Aff-Vis')]
        [Parameter(ParameterSetName = 'ListByOrg')]
        [Parameter(ParameterSetName = 'ListByUser')]
        [ValidateSet('created', 'updated', 'pushed', 'full_name')]
        [string] $Sort = 'created',

        # The order to sort by.
        # Default: asc when using full_name, otherwise desc.
        [Parameter(ParameterSetName = 'MyRepos')]
        [Parameter(ParameterSetName = 'ListByOrg')]
        [Parameter(ParameterSetName = 'ListByUser')]
        [ValidateSet('asc', 'desc')]
        [string] $Direction,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'MyRepos')]
        [Parameter(ParameterSetName = 'ListByOrg')]
        [Parameter(ParameterSetName = 'ListByUser')]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30

    )

    DynamicParam {
        $ParamDictionary = New-ParamDictionary

        if ($PSCmdlet.ParameterSetName -in 'MyRepos_Type', 'ListByOrg', 'ListByUser') {

            switch ($PSCmdlet.ParameterSetName) {
                'MyRepos_Type' {
                    $ValidateSet = 'all', 'owner', 'public', 'private', 'member'
                }
                'ListByOrg' {
                    $ValidateSet = 'all', 'public', 'private', 'forks', 'sources', 'member'
                }
                'ListByUser' {
                    $ValidateSet = 'all', 'owner', 'member'
                }
            }

            $dynParam = @{
                Name             = 'Type'
                ParameterSetName = $PSCmdlet.ParameterSetName
                Type             = [string]
                Mandatory        = $false
                ValidateSet      = $ValidateSet
                ParamDictionary  = $ParamDictionary
            }
            New-DynamicParam @dynParam
        }

        return $ParamDictionary
    }

    Process {
        $Type = $PSBoundParameters['Type']

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
                Remove-HashTableEntries -Hashtable $params -NullOrEmptyValues
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
                Remove-HashTableEntries -Hashtable $params -NullOrEmptyValues
                Get-GitHubMyRepositories @params
            }
            'ByName' {
                $params = @{
                    Owner = $Owner
                    Repo  = $Repo
                }
                Remove-HashTableEntries -Hashtable $params -NullOrEmptyValues
                Get-GitHubRepositoryByName @params
            }
            'ListByID' {
                $params = @{
                    Since = $SinceID
                }
                Remove-HashTableEntries -Hashtable $params -NullOrEmptyValues
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
                Remove-HashTableEntries -Hashtable $params -NullOrEmptyValues
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
                Remove-HashTableEntries -Hashtable $params -NullOrEmptyValues
                Get-GitHubRepositoryListByUser @params
            }
        }
    }
}
