filter Get-GitHubRepositoryByNameAndTeam {
    <#
        .SYNOPSIS
        Get the permission level for a team on a repository.

        .DESCRIPTION
        Retrieves the permission level assigned to a specific team for a given GitHub repository.

        .EXAMPLE
        Get-GitHubRepositoryByNameAndTeam -Owner 'octocat' -Name 'Hello-World' -Team 'core'

        Output:
        ```powershell
        
        ```

        Retrieves the permission of the 'core' team on the 'Hello-World' repository owned by 'octocat'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRepository

        .NOTES
        [Check team permissions for a repository](https://docs.github.com/rest/teams/teams#check-team-permissions-for-a-repository)
    #>
    [OutputType([GitHubRepository])]
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
    }

    process {
        $TeamOwner = [string]::IsNullOrEmpty($TeamOwner) ? $Owner : $TeamOwner
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/orgs/$TeamOwner/teams/$Team/repos/$Owner/$Name"
            Accept      = 'application/vnd.github.v3.repository+json'
            Context     = $Context
        }
        try {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                [GitHubRepository]::new($_.Response)
            }
        } catch {
            Write-Debug "Team '$Team' does not have access to repository $Owner/$Name."
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
