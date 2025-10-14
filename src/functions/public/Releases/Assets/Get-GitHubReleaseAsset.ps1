filter Get-GitHubReleaseAsset {
    <#
        .SYNOPSIS
        List release assets based on a release ID, asset ID, or asset name

        .DESCRIPTION
        If an asset ID is provided, the asset is returned.
        If a release ID is provided, all assets for the release are returned.
        If a release ID and name are provided, the specific named asset from that release is returned.
        If a tag and name are provided, the specific named asset from the release with that tag is returned.

        .EXAMPLE
        ```powershell
        Get-GitHubReleaseAsset -Owner 'octocat' -Repository 'hello-world' -ID '1234567'
        ```

        Gets the release asset with the ID '1234567' for the repository 'octocat/hello-world'.

        .EXAMPLE
        ```powershell
        Get-GitHubReleaseAsset -Owner 'octocat' -Repository 'hello-world' -ReleaseID '7654321'
        ```

        Gets all release assets for the release with the ID '7654321' for the repository 'octocat/hello-world'.

        .EXAMPLE
        ```powershell
        Get-GitHubReleaseAsset -Owner 'octocat' -Repository 'hello-world' -ReleaseID '7654321' -Name 'example.zip'
        ```

        Gets the release asset named 'example.zip' from the release with ID '7654321' for the repository 'octocat/hello-world'.

        .EXAMPLE
        ```powershell
        Get-GitHubReleaseAsset -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0' -Name 'example.zip'
        ```

        Gets the release asset named 'example.zip' from the release tagged as 'v1.0.0' for the repository 'octocat/hello-world'.

        .INPUTS
        GitHubRelease

        .OUTPUTS
        GitHubReleaseAsset

        .LINK
        https://psmodule.io/GitHub/Functions/Releases/Assets/Get-GitHubReleaseAsset
    #>
    [OutputType([GitHubReleaseAsset])]
    [CmdletBinding(DefaultParameterSetName = 'List assets from the latest release')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The unique identifier of the asset.
        [Parameter(Mandatory, ParameterSetName = 'Get a specific asset by ID')]
        [string] $ID,

        # The unique identifier of the release.
        [Parameter(Mandatory, ParameterSetName = 'List assets from a release by ID', ValueFromPipelineByPropertyName)]
        [Alias('Release')]
        [string] $ReleaseID,

        # The tag name of the release.
        [Parameter(Mandatory, ParameterSetName = 'List assets from a release by tag')]
        [string] $Tag,

        # The name of the asset to get. If specified, only assets with this name will be returned.
        [Parameter()]
        [string] $Name,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'List assets from the latest release')]
        [Parameter(ParameterSetName = 'List assets from a release by ID')]
        [Parameter(ParameterSetName = 'List assets from a release by tag')]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $params = @{
            Owner      = $Owner
            Repository = $Repository
            Context    = $Context
            Name       = $Name
        }
        $params | Remove-HashtableEntry -NullOrEmptyValues

        switch ($PSCmdlet.ParameterSetName) {
            'List assets from the latest release' {
                Get-GitHubReleaseAssetFromLatest @params -PerPage $PerPage
            }
            'List assets from a release by ID' {
                Get-GitHubReleaseAssetByReleaseID @params -ID $ReleaseID -PerPage $PerPage
            }
            'List assets from a release by tag' {
                Get-GitHubReleaseAssetByTag @params -Tag $Tag -PerPage $PerPage
            }
            'Get a specific asset by ID' {
                Get-GitHubReleaseAssetByID @params -ID $ID
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
