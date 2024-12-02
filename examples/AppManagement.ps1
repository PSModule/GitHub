# Install an app on the entire enterprise
$enterpriseOrgs = Get-GitHubEnterpriseInstallableOrganization -Enterprise 'msx'
$enterpriseOrgs | Install-GitHubAppOnEnterpriseOrganization -Enterprise 'msn' -Organization $_.login -ClientID '123' -RepositorySelection all
