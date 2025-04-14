filter New-GitHubRepositoryAsFork {
    <#
        .SYNOPSIS
        Create a fork

        .DESCRIPTION
        Create a fork for the authenticated user.

        **Note**: Forking a Repository happens asynchronously. You may have to wait a short period of time before you can access the git objects.
        If this takes longer than 5 minutes, be sure to contact [GitHub Support](https://support.github.com/contact?tags=dotcom-rest-api).

        **Note**: Although this endpoint works with GitHub Apps, the GitHub App must be installed on the destination account with access to all
        repositories and on the source account with access to the source repository.

        .EXAMPLE
        New-GitHubRepositoryAsFork -ForkOwner 'github' -ForkRepository 'Hello-World'

        Fork the repository `Hello-World` owned by `github` for the authenticated user.
        Repo will be named `Hello-World`, and all branches and tags will be forked.

        .EXAMPLE
        New-GitHubRepositoryAsFork -ForkOwner 'github' -ForkRepository 'Hello-World' -Name 'Hello-World-2'

        Fork the repository `Hello-World` owned by `github` for the authenticated user, naming the resulting repository `Hello-World-2`.

        .EXAMPLE
        New-GitHubRepositoryAsFork -ForkOwner 'github' -ForkRepository 'Hello-World' -Owner 'octocat'

        Fork the repository `Hello-World` owned by `github` for the organization `octocat`, naming the resulting repository `Hello-World`.

        .EXAMPLE
        New-GitHubRepositoryAsFork -ForkOwner 'github' -ForkRepository 'Hello-World' -DefaultBranchOnly

        Fork the repository `Hello-World` owned by `github` for the authenticated user, forking only the default branch.

        .OUTPUTS
        GitHubRepository

        .LINK
        [Create a fork](https://docs.github.com/rest/repos/forks#create-a-fork)
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The organization or person who will own the new repository.
        # To create a new repository in an organization, the authenticated user must be a member of the specified organization.
        [Parameter()]
        [string] $Organization,

        # The name of the new repository.
        [Parameter()]
        [string] $Name,

        # When forking from an existing repository, fork with only the default branch.
        [Parameter()]
        [switch] $DefaultBranchOnly,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            organization        = $Organization
            name                = $Name
            default_branch_only = $DefaultBranchOnly
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = "/repos/$Owner/$Repository/forks"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Repository [$Organization/$Name] as fork of [$Owner/$Repository]", 'Create')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                [GitHubRepository]::New($_.Response)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
