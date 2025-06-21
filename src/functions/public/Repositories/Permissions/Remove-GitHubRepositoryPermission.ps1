filter Remove-GitHubRepositoryPermission {
    <#
        .SYNOPSIS
        Remove the permission level for a team on a repository.

        .DESCRIPTION
        This function removes a team's access to a specific repository within an organization.

        .EXAMPLE
        Remove-GitHubRepositoryPermission -Owner 'my-org' -Name 'repo-name' -Team 'dev-team'

        Removes the 'dev-team' permissions from the 'repo-name' repository under 'my-org'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        void

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Remove-GitHubRepositoryPermission/

        .NOTES
        [Remove a repository from a team](https://docs.github.com/rest/teams/teams#remove-a-repository-from-a-team)
    #>
    [OutputType([void])]
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
        $inputObject = @{
            Method      = 'DELETE'
            APIEndpoint = "/orgs/$TeamOwner/teams/$Team/repos/$Owner/$Name"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Team [$TeamOwner/$Team] repository permission on [$Owner/$Name]", 'Remove')) {
            $null = Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
