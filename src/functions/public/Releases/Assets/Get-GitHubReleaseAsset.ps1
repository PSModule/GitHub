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
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

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
        [string] $ReleaseID,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner: [$Owner]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo: [$Repo]"
    }

    process {
        try {
            if ($ReleaseID) {
                Get-GitHubReleaseAssetByReleaseID -Owner $Owner -Repo $Repo -ReleaseID $ReleaseID -Context $Context
            }
            if ($ID) {
                Get-GitHubReleaseAssetByID -Owner $Owner -Repo $Repo -ID $ID -Context $Context
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
