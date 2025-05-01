filter Get-GitHubReleaseAssetFromLatest {
    <#
        .SYNOPSIS
        Get the assets of the latest release

        .DESCRIPTION
        Gets all assets for the latest published full release for the repository.
        The latest release is the most recent non-prerelease, non-draft release, sorted by the `created_at` attribute.
        The `created_at` attribute is the date of the commit used for the release, and not the date when the release was drafted or published.

        .EXAMPLE
        Get-GitHubReleaseAssetFromLatest -Owner 'octocat' -Repository 'hello-world'

        Gets the assets for the latest release of the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubReleaseAsset
    #>
    [OutputType([GitHubReleaseAsset])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

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
        $hasNextPage = $true
        $after = $null
        $perPageSetting = Resolve-GitHubContextSetting -Name 'PerPage' -Value $PerPage -Context $Context

        do {
            $inputObject = @{
                Query     = @'
query($owner: String!, $repository: String!, $perPage: Int, $after: String) {
  repository(owner: $owner, name: $repository) {
    latestRelease {
      releaseAssets(first: $perPage, after: $after) {
        nodes {
          id
          name
          contentType
          size
          downloadCount
          downloadUrl
          url
          createdAt
          updatedAt
          uploadedBy {
            login
          }
        }
        pageInfo {
          endCursor
          hasNextPage
        }
      }
    }
  }
}
'@
                Variables = @{
                    owner      = $Owner
                    repository = $Repository
                    perPage    = $perPageSetting
                    after      = $after
                }
                Context   = $Context
            }

            Invoke-GitHubGraphQLQuery @inputObject | ForEach-Object {
                $release = $_.repository.latestRelease
                $assets = $release.releaseAssets
                foreach ($asset in $assets.nodes) {
                    [GitHubReleaseAsset]::new($asset)
                }
                $hasNextPage = $assets.pageInfo.hasNextPage
                $after = $assets.pageInfo.endCursor
            }
        } while ($hasNextPage)
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
