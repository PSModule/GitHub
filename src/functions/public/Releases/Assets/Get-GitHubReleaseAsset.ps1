filter Get-GitHubReleaseAsset {
    <#
        .SYNOPSIS
        List release assets based on a release ID or asset ID

        .DESCRIPTION
        If an asset ID is provided, the asset is returned.
        If a release ID is provided, all assets for the release are returned.

        .EXAMPLE
        Get-GitHubReleaseAsset -Owner 'octocat' -Repo 'hello-world' -ID '1234567'

        Gets the release asset with the ID '1234567' for the repository 'octocat/hello-world'.

        .EXAMPLE
        Get-GitHubReleaseAsset -Owner 'octocat' -Repo 'hello-world' -ReleaseID '7654321'

        Gets the release assets for the release with the ID '7654321' for the repository 'octocat/hello-world'.

        .NOTES
        [Get a release asset](https://docs.github.com/rest/releases/assets#get-a-release-asset)

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
        [Parameter(
            Mandatory,
            ParameterSetName = 'ID'
        )]
        [Alias('asset_id')]
        [string] $ID,

        # The unique identifier of the release.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ReleaseID'
        )]
        [Alias('release_id')]
        [string] $ReleaseID
    )

    if ($ReleaseID) {
        Get-GitHubReleaseAssetByReleaseID -Owner $Owner -Repo $Repo -ReleaseID $ReleaseID
    }
    if ($ID) {
        Get-GitHubReleaseAssetByID -Owner $Owner -Repo $Repo -ID $ID
    }

}
