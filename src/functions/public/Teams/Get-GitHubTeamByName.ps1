function Get-GitHubTeamByName {
    <#
        .SYNOPSIS
        Get a team by name

        .DESCRIPTION
        Gets a team using the team's slug. To create the slug, GitHub replaces special characters in the name string, changes all words to lowercase,
        and replaces spaces with a - separator. For example, "My TEam Näme" would become my-team-name.

        .EXAMPLE
        Get-GitHubTeamByName -Organization 'github' -Name 'my-team-name'

        .NOTES
        [Get team by name](https://docs.github.com/en/rest/teams/teams#get-a-team-by-name)
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Org')]
        [string] $Organization,

        # The slug of the team name.
        [Parameter(Mandatory)]
        [Alias('Team', 'TeamName', 'slug', 'team_slug')]
        [string] $Name,

        # The context to run the command in
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name DefaultContext)
    )

    $contextObj = Get-GitHubContext -Context $Context
    if (-not $contextObj) {
        throw 'Log in using Connect-GitHub before running this command.'
    }
    Write-Debug "Context: [$Context]"

    if ([string]::IsNullOrEmpty($Owner)) {
        $Owner = $contextObj.Owner
    }
    Write-Debug "Owner : [$($contextObj.Owner)]"

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/orgs/$Organization/teams/$Name"
        Method      = 'Get'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
