filter Remove-GitHubReleaseAsset {
    <#
        .SYNOPSIS
        Delete a release asset

        .DESCRIPTION
        Delete a release asset

        .EXAMPLE
        Remove-GitHubReleaseAsset -Owner 'octocat' -Repo 'hello-world' -ID '1234567'

        Deletes the release asset with the ID '1234567' for the repository 'octocat/hello-world'.

        .NOTES
        https://docs.github.com/rest/releases/assets#delete-a-release-asset

    #>
    [CmdletBinding()]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The unique identifier of the asset.
        [Parameter(Mandatory)]
        [Alias('asset_id')]
        [string] $ID
    )

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/releases/assets/$ID"
        Method      = 'DELETE'
    }

    (Invoke-GitHubAPI @inputObject).Response

}
