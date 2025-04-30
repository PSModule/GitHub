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
        Get-GitHubReleaseAsset -Owner 'octocat' -Repository 'hello-world' -ID '1234567'

        Gets the release asset with the ID '1234567' for the repository 'octocat/hello-world'.

        .EXAMPLE
        Get-GitHubReleaseAsset -Owner 'octocat' -Repository 'hello-world' -ReleaseID '7654321'

        Gets all release assets for the release with the ID '7654321' for the repository 'octocat/hello-world'.

        .EXAMPLE
        Get-GitHubReleaseAsset -Owner 'octocat' -Repository 'hello-world' -ReleaseID '7654321' -Name 'example.zip'

        Gets the release asset named 'example.zip' from the release with ID '7654321' for the repository 'octocat/hello-world'.

        .EXAMPLE
        Get-GitHubReleaseAsset -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0' -Name 'example.zip'

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
        [Parameter(Mandatory, ParameterSetName = 'List assets from a release', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Get a specific asset by name from a release ID', ValueFromPipelineByPropertyName)]
        [string] $ReleaseID,

        # The tag name of the release.
        [Parameter(Mandatory, ParameterSetName = 'Get a specific asset by name from a tag')]
        [string] $Tag,

        # The name of the asset to find.
        [Parameter(Mandatory, ParameterSetName = 'Get a specific asset by name from a release ID')]
        [Parameter(Mandatory, ParameterSetName = 'Get a specific asset by name from a tag')]
        [string] $Name,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

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
        $params = @{
            Owner      = $Owner
            Repository = $Repository
            PerPage    = $PerPage
            Context    = $Context
        }
        $params | Remove-HashtableEntry -NullOrEmptyValues

        switch ($PSCmdlet.ParameterSetName) {
            'List assets from the latest release' {
                Get-GitHubReleaseAssetFromLatest @params
            }
            'List assets from a release' {
                Get-GitHubReleaseAssetByReleaseID @params -ID $ReleaseID
            }
            'Get a specific asset by ID' {
                Get-GitHubReleaseAssetByID @params -ID $ID
            }
            'Get a specific asset by name from a release ID' {
                $assets = Get-GitHubReleaseAssetByReleaseID @params -ID $ReleaseID
                $asset = $assets | Where-Object { $_.Name -eq $Name }
                if ($asset) {
                    $asset
                } else {
                    Write-Warning "Asset with name '$Name' not found in release with ID '$ReleaseID'"
                }
            }
            'Get a specific asset by name from a tag' {
                Get-GitHubReleaseAssetByTag @params -Tag $Tag -Name $Name
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
