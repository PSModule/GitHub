# When Apps connect they should be able to dynamically just get the installation access token.

Connect-GitHub -ClientID '<client_id>' -PrivateKey '<private_key>' # -> APP context (NOT IAT)

<#
Use the APP context to get the installation access token dynamically when querying orgs and repos.
Storing the context as:
- hostName/appSlug[bot]/orgName/repoName
- hostName/appSlug[bot]@orgName/repoName
- hostName/appSlug/orgName/repoName
- hostName/appSlug
  - subcontexts: orgName/repoName as an array of objects storing IAT, validity, org, repo.
#>
Get-GitHubOrganization -Name 'psmodule' # -> gets IAT for PSModule and runs API calls as the IAT, not the app.



LogGroup "Connect to org [$env:GITHUB_REPOSITORY_OWNER]" {
    # $org = $env:GITHUB_REPOSITORY_OWNER
    $appContext = Get-GitHubConfig -Name DefaultContext
    Write-Verbose (Get-GitHubContext | Select-Object *) -Verbose
    $orgInstallations = Get-GitHubAppInstallation | Where-Object { $_.Target_type -eq 'Organization' }

    $orgInstallations | ForEach-Object {
        $orgName = $_.account.login
        $orgInstallationID = $_.id
        Write-Host "Processing [$orgName] [$orgInstallationID]"
        Set-GitHubDefaultContext -Context $appContext
        $token = New-GitHubAppInstallationAccessToken -InstallationID $_.id | Select-Object -ExpandProperty Token
        Connect-GitHub -Token $token -Silent

        '<DO SOMETHING>'

        #Disconnect-GitHub
    }
    #Disconnect-GitHub -Context $appContext
}
