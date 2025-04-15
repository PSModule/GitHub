function Get-GitHubReleaseQL {
    <#
        .SYNOPSIS
        Get all releases with nested pagination for assets

        .DESCRIPTION
        Gets all releases with their complete asset lists using nested pagination through both releases and their assets.

        .EXAMPLE
        Get-GitHubRelease -Owner 'github' -Repository 'my-repo' -PerPage 10 -Context $context
    #>
    [OutputType([GitHubRelease])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Owner,

        [Parameter(Mandatory)]
        [string] $Repository,

        [ValidateRange(1, 100)]
        [int] $PerPage,

        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT

        # Initialize pagination state
        $releaseCursor = $null
        $releaseQuery = @'
query($owner: String!, $repository: String!, $releaseCursor: String, $perPage: Int!) {
  repository(owner: $owner, name: $repository) {
    releases(first: $perPage, after: $releaseCursor, orderBy: {field: CREATED_AT, direction: DESC}) {
      nodes {
        id
        databaseId
        name
        tagName
        description
        isDraft
        isPrerelease
        isLatest
        createdAt
        publishedAt
        updatedAt
        tag {
          name
          id
        }
        tagCommit {
          oid
        }
        url
        author {
          login
          id
          databaseId
        }
        releaseAssets(first: $perPage) {
          nodes {
            name
            downloadCount
            contentType
            size
            url
            id
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
'@
        $assetQuery = @'
query($releaseId: ID!, $assetCursor: String, $perPage: Int!) {
  node(id: $releaseId) {
    ... on Release {
      releaseAssets(first: $perPage, after: $assetCursor) {
        nodes {
          name
          downloadCount
          contentType
          size
          url
          id
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  }
}
'@

        $PerPage = $PSBoundParameters.ContainsKey('PerPage') ? $PerPage : $Context.PerPage
    }

    process {
        do {
            # Get page of releases with first page of assets
            $releaseVariables = @{
                owner         = $Owner
                repository    = $Repository
                releaseCursor = $releaseCursor
                perPage       = $PerPage
            }

            $result = Invoke-GitHubGraphQLQuery -Query $releaseQuery -Variables $releaseVariables -Context $Context
            if (-not $result) { break }

            $repositoryData = $result.data.repository
            if (-not $repositoryData) { break }

            $releases = $repositoryData.releases
            if (-not $releases) { break }

            # Process each release in current page
            foreach ($releaseNode in $releases.nodes) {
                $releaseId = $releaseNode.id
                $assets = @($releaseNode.releaseAssets.nodes)
                $assetPageInfo = $releaseNode.releaseAssets.pageInfo

                # Paginate through remaining asset pages
                while ($assetPageInfo.hasNextPage) {
                    $assetVariables = @{
                        releaseId   = $releaseId
                        assetCursor = $assetPageInfo.endCursor
                        perPage     = $PerPage
                    }

                    $assetResult = Invoke-GitHubGraphQLQuery -Query $assetQuery -Variables $assetVariables -Context $Context
                    if (-not $assetResult) { break }

                    $releaseAssets = $assetResult.data.node.releaseAssets
                    if (-not $releaseAssets) { break }

                    $assets += $releaseAssets.nodes
                    $assetPageInfo = $releaseAssets.pageInfo
                }

                # Create complete release object with all assets
                $releaseNode.releaseAssets.nodes = $assets
                # [GitHubRelease]::new($releaseNode)
                $releaseNode
            }

            # Update release cursor for next page
            $releaseCursor = $releases.pageInfo.endCursor
        } while ($releases.pageInfo.hasNextPage)
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
