function Get-GitHubTeam {
    <#
        .SYNOPSIS
        List teams from an org or get a team by name

        .DESCRIPTION
        Lists all teams in an organization that are visible to the authenticated user or gets a team using the team's slug.
        To create the slug, GitHub replaces special characters in the name string, changes all words to lowercase,
        and replaces spaces with a - separator. For example, "My TEam Näme" would become my-team-name.

        .EXAMPLE
        Get-GitHubTeam -Organization 'GitHub'

        Gets all teams in the `github` organization.

        .EXAMPLE
        Get-GitHubTeam -Organization 'github' -Name 'my-team-name'

        Gets the team with the slug 'my-team-name' in the `github` organization.
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        # The slug of the team name.
        [Parameter(Mandatory)]
        [Alias('team_slug', 'Name')]
        [string] $Slug,

        # The organization name. The name is not case sensitive.
        # If not provided, the owner from the context will be used.
        [Parameter()]
        [Alias('Org')]
        [string] $Organization,

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
            $params = @{
                Organization = $Organization
                Context      = $Context
            }
            switch ($PSCmdlet.ParameterSetName) {
                'GetByName' {
                    Get-GitHubTeamByName @params -Slug $Slug
                }
                '__AllParameterSets' {
                    Get-GitHubTeamListByOrg @params
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
