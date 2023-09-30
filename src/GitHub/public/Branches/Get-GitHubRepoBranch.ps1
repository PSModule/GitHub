function Get-GitHubRepoBranch {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo)
    )

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/branches"
        Method      = 'GET'
    }

    (Invoke-GitHubAPI @inputObject).Response

}
