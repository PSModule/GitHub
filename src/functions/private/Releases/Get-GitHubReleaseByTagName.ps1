filter Get-GitHubReleaseByTagName {
    <#
        .SYNOPSIS
        Get a release by tag name

        .DESCRIPTION
        Get a published release with the specified tag.

        .EXAMPLE
        Get-GitHubReleaseByTagName -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0'

        Gets the release with the tag 'v1.0.0' for the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRelease

        .NOTES
        [Get a release by tag name](https://docs.github.com/rest/releases/releases#get-a-release-by-tag-name)
    #>
    [OutputType([GitHubRelease])]
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
        $apiParams = @{
            Query     = @'
query($owner: String!, $repository: String!, $tag: String!) {
  repository(owner: $owner, name: $repository) {
    release(tagName: $tag) {
      id
      databaseId
      tagName
      name
      description
      isLatest
      isDraft
      isPrerelease
      url
      createdAt
      publishedAt
      updatedAt
      author {
        login
      }
    }
  }
}
'@
            Variables = @{
                owner      = $Owner
                repository = $Repository
                tag        = $Tag
            }
            Context   = $Context
        }

        Invoke-GitHubGraphQLQuery @apiParams | ForEach-Object {
            $release = $_.repository.release
            if ($release) {
                [GitHubRelease]::new($release, $Owner, $Repository, $null)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
