filter Get-GitHubRepositoryPermission {
    <#
        .SYNOPSIS
        Get the permission level for a team on a repository.

        .DESCRIPTION
        Retrieves the permission level assigned to a specific team for a given GitHub repository.

        .EXAMPLE
        ```pwsh
        Get-GitHubRepositoryPermission -Owner 'octocat' -Name 'Hello-World' -Team 'core'
        ```

        Output:
        ```pwsh
        Admin
        ```

        Retrieves the permission of the 'core' team on the 'Hello-World' repository owned by 'octocat'.

        .EXAMPLE
        ```pwsh
        ```


        .INPUTS
        GitHubRepository

        .OUTPUTS
        string

        .LINK
        https://psmodule.io/GitHub/Functions/Get-GitHubRepositoryPermission/

        .NOTES
        [Check team permissions for a repository](https://docs.github.com/rest/teams/teams#check-team-permissions-for-a-repository)
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Organization')]
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
        $params = @{
            Context   = $Context
            Owner     = $Owner
            Name      = $Name
            Team      = $Team
            TeamOwner = $TeamOwner
        }
        $repo = Get-GitHubRepositoryByNameAndTeam @params
        if ($null -eq $repo) {
            Write-Debug "[$stackPath] - No permission found for team '$Team' on repository '$Name' owned by '$Owner'."
            return $null
        }
        $repo.Permission
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
