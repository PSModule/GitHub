$ClientIDs = @(
    'Iv1.f26b61bc99e69405'
)
$Enterprise = 'msx'
$Organization = '*'

$installableOrgs = Get-GitHubOrganization -Enterprise $Enterprise
$orgs = $installableOrgs | Where-Object { $_.Name -like $organization }
foreach ($org in $orgs) {
    foreach ($ClientID in $ClientIDs) {
        Install-GitHubApp -Enterprise $Enterprise -Organization $org.Name -ClientID $ClientID -RepositorySelection all
    }
}
