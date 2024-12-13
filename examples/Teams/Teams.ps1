$filter = 'my-org'

$allOrgs = Get-GitHubOrganization $filter -Verbose
$orgs = $allOrgs | Where-Object { $_.login -like $filter }

$orgs | Select-Object login, id, disk_usage
foreach ($org in $orgs) {
    1..100 | ForEach-Object {
        New-GitHubTeam -Organization $org.login -Name "Team$_" -Description "Team $_" -Verbose
    }
}


$Teams = Get-GitHubTeamListByOrg -Organization $filter | ForEach-Object {
    [pscustomobject]@{
        Organization = $filter
        Name         = $_.name
        Id           = $_.id
    }
}


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


$Teams | Where-Object { $_.Name -like 'Team*' } | ForEach-Object {
    Remove-GitHubTeam -Organization $_.Organization -Name $_.Name -Verbose
}
