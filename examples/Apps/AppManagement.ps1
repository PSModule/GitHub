# Install an app on the entire enterprise
$appIDs = @(
    'Iv1.f26b61bc99e69405'
)
$orgs = Get-GitHubOrganization -Enterprise 'msx'
foreach ($org in $orgs) {
    foreach ($appID in $appIDs) {
        Install-GitHubApp -Enterprise msx -Organization $org.login -ClientID $appID -RepositorySelection all
    }
}
