$ClientID = ''
$PrivateKey = @'
-----BEGIN RSA PRIVATE KEY-----

-----END RSA PRIVATE KEY-----
'@
Connect-GitHub -ClientID $ClientID -PrivateKey $PrivateKey
Connect-GitHubApp -Enterprise 'msx'

# The apps you want to install on orgs in the enterprise
$ClientIDs = @(
    'Iv1.f26b61bc99e69405'
)
$Enterprise = 'msx'
$Organization = '*'

$installableOrgs = Get-GitHubOrganization -Enterprise $Enterprise
$orgs = $installableOrgs | Where-Object { $_.Name -like $Organization }
foreach ($org in $orgs) {
    foreach ($ClientID in $ClientIDs) {
        Install-GitHubApp -Enterprise $Enterprise -Organization $org.Name -ClientID $ClientID -RepositorySelection all
    }
}
