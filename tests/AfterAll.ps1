[CmdletBinding()]
param()

LogGroup 'AfterAll - Global Test Teardown' {


    switch ($OwnerType) {
        'user' {
            Get-GitHubRepository | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
        }
        'organization' {
            Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
        }
    }
    Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
    Write-Host ('-' * 60)
}
