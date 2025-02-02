#Requires -Modules @{ ModuleName = 'GitHub'; RequiredVersion = '0.13.2' }

# Install an app on the entire enterprise
$appIDs = @(
    'Iv1.f26b61bc99e69405'
)
$orgs = Get-GitHubEnterpriseInstallableOrganization -Enterprise 'msx'
foreach ($org in $orgs) {
    foreach ($appID in $appIDs) {
        Install-GitHubAppOnEnterpriseOrganization -Enterprise msx -Organization $org.login -ClientID $appID -RepositorySelection all
    }
}
