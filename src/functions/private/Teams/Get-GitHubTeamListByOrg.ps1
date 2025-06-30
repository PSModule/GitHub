function Get-GitHubTeamListByOrg {
    <#
        .SYNOPSIS
        List teams

        .DESCRIPTION
        Lists all teams in an organization that are visible to the authenticated user.

        .EXAMPLE
        Get-GitHubTeamListByOrg -Organization 'github'

        .OUTPUTS
        GitHubTeam[]

        .NOTES
        [List teams](https://docs.github.com/rest/teams/teams#list-teams)
    #>
    [OutputType([GitHubTeam[]])]
    [CmdletBinding()]
    param(
        # The organization name. The name is not case sensitive.
        # If you don't provide this parameter, the command will use the owner of the context.
        [Parameter(Mandatory)]
        [string] $Organization,

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
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/orgs/$Organization/teams"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            foreach ($team in $_.Response) {
                [GitHubTeam]::new($team, $Organization)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
