filter Get-GitHubReleaseLatest {
    <#
        .SYNOPSIS
        Get the latest release

        .DESCRIPTION
        View the latest published full release for the repository.
        The latest release is the most recent non-prerelease, non-draft release, sorted by the `created_at` attribute.
        The `created_at` attribute is the date of the commit used for the release, and not the date when the release was drafted or published.

        .EXAMPLE
        Get-GitHubReleaseLatest -Owner 'octocat' -Repository 'hello-world'

        Gets the latest releases for the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRelease

        .LINK
        [Get the latest release](https://docs.github.com/rest/releases/releases#get-the-latest-release)
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
            Query     = @'
query($owner: String!, $repository: String!) {
  repository(owner: $owner, name: $repository) {
    latestRelease {
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
            }
            Context   = $Context
        }

        Invoke-GitHubGraphQLQuery @inputObject | ForEach-Object {
            $release = $_.repository.latestRelease
            if ($release) {
                [GitHubRelease]::new($release, $Owner, $Repository, $null)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
