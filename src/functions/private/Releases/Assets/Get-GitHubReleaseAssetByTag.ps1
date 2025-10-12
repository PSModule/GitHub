filter Get-GitHubReleaseAssetByTag {
    <#
        .SYNOPSIS
        Get release assets by tag name

        .DESCRIPTION
        Gets all assets from a release identified by its tag name.
        Uses pagination to retrieve all assets even if there are more than the maximum per page.

        .EXAMPLE
        ```pwsh
        Get-GitHubReleaseAssetByTag -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0'
        ```

        Gets all release assets for the release with the tag 'v1.0.0' for the repository 'octocat/hello-world'.

        .EXAMPLE
        ```pwsh
        Get-GitHubReleaseAssetByTag -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0' -Name 'app.zip'
        ```

        Gets a specific release asset named 'app.zip' from the release with the tag 'v1.0.0' for the repository 'octocat/hello-world'.

        .OUTPUTS
        GitHubReleaseAsset
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', 'hasNextPage', Scope = 'Function',
        Justification = 'Unknown issue with var scoping in blocks.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', 'after', Scope = 'Function',
        Justification = 'Unknown issue with var scoping in blocks.'
    )]
    [OutputType([GitHubReleaseAsset])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The name of the tag to get a release from.
        [Parameter(Mandatory)]
        [string] $Tag,

        # The name of the asset to get. If specified, only assets with this name will be returned.
        [Parameter()]
        [string] $Name,

        # The number of results per page (max 100).
        [Parameter()]
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
        $hasNextPage = $true
        $after = $null
        $nameParam = $PSBoundParameters.ContainsKey('Name') ? ", name: ""$Name""" : ''
        $perPageSetting = Resolve-GitHubContextSetting -Name 'PerPage' -Value $PerPage -Context $Context

        do {
            $apiParams = @{
                Query     = @"
query(`$owner: String!, `$repository: String!, `$tag: String!, `$perPage: Int, `$after: String) {
  repository(owner: `$owner, name: `$repository) {
    release(tagName: `$tag) {
      releaseAssets(first: `$perPage, after: `$after$nameParam) {
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
"@
                Variables = @{
                    owner      = $Owner
                    repository = $Repository
                    tag        = $Tag
                    perPage    = $perPageSetting
                    after      = $after
                }
                Context   = $Context
            }

            Invoke-GitHubGraphQLQuery @apiParams | ForEach-Object {
                $release = $_.repository.release
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
