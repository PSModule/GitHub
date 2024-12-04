function Get-GitHubTeamListByOrg {
    <#
        .SYNOPSIS
        List teams

        .DESCRIPTION
        Lists all teams in an organization that are visible to the authenticated user.

        .EXAMPLE
        Get-GitHubTeamListByOrg -Organization 'github'

        .NOTES
        [List teams](https://docs.github.com/rest/teams/teams#list-teams)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Org')]
        [string] $Organization,

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
        APIEndpoint = "/orgs/$Organization/teams"
        Method      = 'Get'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
