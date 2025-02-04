filter Get-GitHubReleaseAsset {
    <#
        .SYNOPSIS
        List release assets based on a release ID or asset ID

        .DESCRIPTION
        If an asset ID is provided, the asset is returned.
        If a release ID is provided, all assets for the release are returned.

        .EXAMPLE
        Get-GitHubReleaseAsset -Owner 'octocat' -Repository 'hello-world' -ID '1234567'

        Gets the release asset with the ID '1234567' for the repository 'octocat/hello-world'.

        .EXAMPLE
        Get-GitHubReleaseAsset -Owner 'octocat' -Repository 'hello-world' -ReleaseID '7654321'

        Gets the release assets for the release with the ID '7654321' for the repository 'octocat/hello-world'.

        .NOTES
        [Get a release asset](https://docs.github.com/rest/releases/assets#get-a-release-asset)
    #>
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

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
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ReleaseID' {
                Get-GitHubReleaseAssetByReleaseID -Owner $Owner -Repository $Repository -ReleaseID $ReleaseID -Context $Context
            }
            'ID' {
                Get-GitHubReleaseAssetByID -Owner $Owner -Repository $Repository -ID $ID -Context $Context
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
