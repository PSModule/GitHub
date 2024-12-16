function Remove-GitHubTeam {
    <#
        .SYNOPSIS
        Delete a team

        .DESCRIPTION
        To delete a team, the authenticated user must be an organization owner or team maintainer.
        If you are an organization owner, deleting a parent team will delete all of its child teams as well.

        .EXAMPLE
        Remove-GitHubTeam -Organization 'github' -Name 'team-name'

        .NOTES
        [Delete a team](https://docs.github.com/en/rest/teams/teams?apiVersion=2022-11-28#delete-a-team)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Org')]
        [string] $Organization,

        # The slug of the team name.
        [Parameter(Mandatory)]
        [Alias('Team', 'TeamName', 'slug', 'team_slug')]
        [string] $Name,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT

        if ([string]::IsNullOrEmpty($Organization)) {
            $Organization = $Context.Owner
        }
        Write-Debug "Organization: [$Organization]"
    }

    process {
        try {
            $inputObject = @{
                Context     = $Context
                Method      = 'Delete'
                APIEndpoint = "/orgs/$Organization/teams/$Name"
            }

            if ($PSCmdlet.ShouldProcess("$Organization/$Name", 'Delete')) {
                Invoke-GitHubAPI @inputObject | ForEach-Object {
                    Write-Output $_.Response
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
