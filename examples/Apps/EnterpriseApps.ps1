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

    begin {

    }

    process {
        $installableOrgs = Get-GitHubAppInstallableOrganization -Enterprise $Enterprise -Debug -Verbose #FIXME: Add '#Requires -Modules' for [Get-GitHubEnterpriseInstallableOrganization] Suggestions: GitHub
        $orgs = $installableOrgs | Where-Object { $_.login -like $organization }
        foreach ($org in $orgs) {
            foreach ($appIDitem in $AppID) {
                Install-GitHubAppOnEnterpriseOrganization -Enterprise $Enterprise -Organization $org.login -ClientID $appIDitem -RepositorySelection all | ForEach-Object {
                    [PSCustomObject]@{
                        Organization = $org.login
                        AppID        = $appIDitem
                    }
                }
            }
        }
    }

    end {

    }
}

$appIDs | Install-GithubApp -Organization $organization -Debug -Verbose

$installation = Get-GitHubAppInstallation
