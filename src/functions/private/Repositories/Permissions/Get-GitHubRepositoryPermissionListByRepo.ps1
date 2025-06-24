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
                [GitHubRepositoryTeam]::new($team)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
