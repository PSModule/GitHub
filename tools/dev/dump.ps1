

function Get-GitHubRepository {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $OrganizationName,

        [Parameter(Mandatory)]
        [string] $Token,

        [Parameter()]
        $BaseURL = $env:GITHUB_API_URL
    )

    $result = Invoke-RestMethod -Method Get -Uri "$BaseURL/orgs/$OrganizationName/repos" -Headers @{
        'Authorization' = "Bearer $token"
        'Accept'        = 'application/vnd.github+json'
    } -FollowRelLink

    $result | ForEach-Object {
        Write-Output $_
    }
}
