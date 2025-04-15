filter Get-GitHubRelease {
    <#
        .SYNOPSIS
        List releases

        .DESCRIPTION
        This returns a list of releases, which does not include regular Git tags that have not been associated with a release.
        To get a list of Git tags, use the [Repository Tags API](https://docs.github.com/rest/repos/repos#list-repository-tags).
        Information about published releases are available to everyone. Only users with push access will receive listings for draft releases.

        .EXAMPLE
        Get-GitHubRelease -Owner 'octocat' -Repository 'hello-world'

        Gets the releases for the repository 'hello-world' owned by 'octocat'.

        .EXAMPLE
        Get-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Latest

        Gets the latest releases for the repository 'hello-world' owned by 'octocat'.

        .EXAMPLE
        Get-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0'

        Gets the release with the tag 'v1.0.0' for the repository 'hello-world' owned by 'octocat'.

        .EXAMPLE
        Get-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -ID '1234567'

        Gets the release with the ID '1234567' for the repository 'hello-world' owned by 'octocat'.

        .NOTES
        [List releases](https://docs.github.com/rest/releases/releases#list-releases)
        [Get the latest release](https://docs.github.com/rest/releases/releases#get-the-latest-release)
    #>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Latest', Justification = 'Required for parameter set')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'All')]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # Get the latest release only
        [Parameter(
            Mandatory,
            ParameterSetName = 'Latest'
        )]
        [switch] $Latest,

        # The name of the tag to get a release from.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Tag'
        )]
        [Alias('tag_name')]
        [string] $Tag,

        # The unique identifier of the release.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ID'
        )]
        [Alias('release_id')]
        [string] $ID,

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
            'All' {
                Get-GitHubReleaseAll -Owner $Owner -Repository $Repository -PerPage $PerPage -Context $Context
            }
            'Latest' {
                Get-GitHubReleaseLatest -Owner $Owner -Repository $Repository -Context $Context
            }
            'Tag' {
                Get-GitHubReleaseByTagName -Owner $Owner -Repository $Repository -Tag $Tag -Context $Context
            }
            'ID' {
                Get-GitHubReleaseByID -Owner $Owner -Repository $Repository -ID $ID -Context $Context
            }
        }

    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
