filter Get-GitHubReleaseAssetByReleaseID {
    <#
        .SYNOPSIS
        List release assets

        .DESCRIPTION
        List release assets

        .EXAMPLE
        Get-GitHubReleaseAssetByReleaseID -Owner 'octocat' -Repository 'hello-world' -ID '1234567'

        Gets the release assets for the release with the ID '1234567' for the repository 'octocat/hello-world'.

        .EXAMPLE
        Get-GitHubReleaseAssetByReleaseID -Owner 'octocat' -Repository 'hello-world' -ID '1234567' -Name 'example.zip'

        Gets only the release asset named 'example.zip' for the release with the ID '1234567'.

        .NOTES
        https://docs.github.com/rest/releases/assets#list-release-assets

    #>
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The unique identifier of the release.
        [Parameter(Mandatory)]
        [string] $ID,

        # The name of a specific asset to return. If provided, only the asset with this name will be returned.
        [Parameter()]
        [string] $Name,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [AllowNull()]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/releases/$ID/assets"
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            foreach ($asset in $_.Response) {
                if ($PSBoundParameters.ContainsKey('Name')) {
                    if ($asset.name -eq $Name) {
                        [GitHubReleaseAsset]($asset)
                        break
                    }
                } else {
                    [GitHubReleaseAsset]($asset)
                }
            }
        }
    }
    end {
        Write-Debug "[$stackPath] - End"
    }
}
