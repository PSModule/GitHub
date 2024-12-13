$orgs = Get-GitHubOrganization
$teams = $orgs | ForEach-Object {
    $org = $_.login
    Get-GitHubTeamListByOrg -Organization $org | ForEach-Object {
        [pscustomobject]@{
            Organization = $org
            Team         = $_.name
            TeamId       = $_.id
        }
    }
}
$teams
