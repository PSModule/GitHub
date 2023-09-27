function Get-GitHubRepoTeam {
    <#
        .NOTES
        https://docs.github.com/en/rest/reference/repos#get-a-repository
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo)
    )

    $inputObject = @{
        Method      = 'Get'
        APIEndpoint = "/repos/$Owner/$Repo/teams"
    }

    $response = Invoke-GitHubAPI @inputObject

    $response
}
