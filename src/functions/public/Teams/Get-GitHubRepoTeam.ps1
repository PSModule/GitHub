filter Get-GitHubRepoTeam {
    <#
        .NOTES
        [List repository teams](https://docs.github.com/rest/reference/repos#get-a-repository)
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubContextSetting -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubContextSetting -Name Repo)
    )

    $inputObject = @{
        Method      = 'Get'
        APIEndpoint = "/repos/$Owner/$Repo/teams"
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
