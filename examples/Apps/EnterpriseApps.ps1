$appIDs = @(
    'qweqweqwe',
    'qweqweqweqwe'
)

$organization = '*'
filter Install-GithubApp {
    param(
        [Parameter()]
        [string] $Enterprise = 'msx',

        [Parameter()]
        [string] $Organization = '*',

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [string] $AppID
    )

    process {
        $installableOrgs = Get-GitHubOrganization -Enterprise $Enterprise
        $orgs = $installableOrgs | Where-Object { $_.login -like $organization }
        foreach ($org in $orgs) {
            foreach ($appIDitem in $AppID) {
                Install-GitHubApp -Enterprise $Enterprise -Organization $org.login -ClientID $appIDitem -RepositorySelection all | ForEach-Object {
                    [PSCustomObject]@{
                        Organization = $org.login
                        AppID        = $appIDitem
                    }
                }
            }
        }
    }
}

$appIDs | Install-GitHubApp -Organization $organization

$installation = Get-GitHubAppInstallation
