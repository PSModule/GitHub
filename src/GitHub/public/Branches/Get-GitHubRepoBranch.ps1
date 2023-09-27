function Get-GitHubRepoBranch {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo)
    )

    $inputObject = @{
        Method      = 'GET'
        APIEndpoint = "/repos/$Owner/$Repo/branches"
    }

    $response = Invoke-GitHubAPI @inputObject

    $response
}
