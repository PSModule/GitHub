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

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    if ([string]::IsNullOrEmpty($Owner)) {
        $Organization = $Context.Owner
    }
    Write-Debug "Organization : [$($Context.Owner)]"

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/orgs/$Organization/teams"
        Method      = 'Get'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
