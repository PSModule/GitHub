filter Get-GitHubReleaseAssetByID {
    <#
        .SYNOPSIS
        Get a release asset

        .DESCRIPTION
        To download the asset's binary content, set the `Accept` header of the request to
        [`application/octet-stream`](https://docs.github.com/rest/overview/media-types).
        The API will either redirect the client to the location, or stream it directly if
        possible. API clients should handle both a `200` or `302` response.

        .EXAMPLE
        Get-GitHubReleaseAssetByID -Owner 'octocat' -Repo 'hello-world' -ID '1234567'

        Gets the release asset with the ID '1234567' for the repository 'octocat/hello-world'.

        .NOTES
        https://docs.github.com/rest/releases/assets#get-a-release-asset

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
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
