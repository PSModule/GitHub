filter Get-GitHubTeamListByRepo {
    <#
        .SYNOPSIS
        List team repositories.

        .DESCRIPTION
        Lists a team's repositories visible to the authenticated user.

        .EXAMPLE
        Get-GitHubTeamListByRepo -Owner 'octocat' -Name 'Hello-World'

        Output:
        ```powershell

        ```

        Lists all teams that have access to the 'Hello-World' repository owned by 'octocat'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubTeam

        .NOTES
        [List team repositories](https://docs.github.com/rest/teams/teams#list-team-repositories)
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
            APIEndpoint = "/repos/$Owner/$Name/teams"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            foreach ($team in $_.Response) {
                [GitHubTeam]::new($team)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
