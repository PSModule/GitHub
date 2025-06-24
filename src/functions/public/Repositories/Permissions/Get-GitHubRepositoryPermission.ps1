filter Get-GitHubRepositoryPermission {
    <#
        .SYNOPSIS
        Get the permission level for a team on a repository.

        .DESCRIPTION
        Retrieves the permission level assigned to a specific team for a given GitHub repository.

        .EXAMPLE
        Get-GitHubRepositoryPermission -Owner 'octocat' -Name 'Hello-World' -Team 'core'

        Output:
        ```powershell
        Admin    : true
        Maintain :
        Push     :
        Triage   :
        Pull     :
        ```

        Retrieves the permission of the 'core' team on the 'Hello-World' repository owned by 'octocat'.

        .EXAMPLE
        # Get a list of teams and their permissions for a specific GitHub repository
        Get-GithubRepositoryPermission -Owner 'OrgName' -Repository 'RepoName'

        # Get a list of repositories and their permissions for a specific GitHub team
        # https://docs.github.com/en/rest/teams/teams?apiVersion=2022-11-28#list-team-repositories
        Get-GithubRepositoryPermission -Owner 'OrgName' -Team 'TeamSlug'

        # Get permission for a specific GitHub repository for a specific team
        # https://docs.github.com/en/rest/teams/teams?apiVersion=2022-11-28#check-team-permissions-for-a-repository
        Get-GithubRepositoryPermission -Owner 'OrgName' -Repository 'RepoName' -Team 'TeamSlug'

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRepositoryPermission

        .LINK
        https://psmodule.io/GitHub/Functions/Get-GitHubRepositoryPermission/

        .NOTES
        [Check team permissions for a repository](https://docs.github.com/rest/teams/teams#check-team-permissions-for-a-repository)
    #>
    [OutputType([GitHubRepositoryPermission])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Name,

        # The slug of the team to add or update repository permissions for.
        [Parameter(Mandatory)]
        [Alias('Slug', 'TeamSlug')]
        [string] $Team,

        # The owner of the team. If not specified, the owner will default to the value of -Owner.
        [Parameter()]
        [string] $TeamOwner,

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
        $TeamOwner = [string]::IsNullOrEmpty($TeamOwner) ? $Owner : $TeamOwner
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/orgs/$TeamOwner/teams/$Team/repos/$Owner/$Name"
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            [GitHubRepositoryPermission]::new($_.Response)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
