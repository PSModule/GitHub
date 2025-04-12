filter Get-GitHubRelease {
    <#
        .SYNOPSIS
        List releases.

        .DESCRIPTION
        This returns a list of releases, which does not include regular Git tags that have not been associated with a release.
        To get a list of Git tags, use the [Repository Tags API](https://docs.github.com/rest/repos/repos#list-repository-tags).
        Information about published releases are available to everyone. Only users with push access will receive listings for draft releases.

        .EXAMPLE
        Get-GitHubRelease -Owner 'octocat' -Repository 'hello-world'

        Gets the releases for the repository 'hello-world' owned by 'octocat'.

        .EXAMPLE
        Get-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -All

        Gets all releases for the repository 'hello-world' owned by 'octocat'.

        .EXAMPLE
        Get-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0'

        Gets the release with the tag 'v1.0.0' for the repository 'hello-world' owned by 'octocat'.

        .EXAMPLE
        Get-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -ID '1234567'

        Gets the release with the ID '1234567' for the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRelease

        .LINK
        https://psmodule.io/GitHub/Functions/Releases/Get-GitHubRelease/

        [List releases](https://docs.github.com/rest/releases/releases#list-releases)
        [Get the latest release](https://docs.github.com/rest/releases/releases#get-the-latest-release)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSReviewUnusedParameter', 'All',
        Justification = 'Using the ParameterSetName to determine the context of the command.'
    )]
    [OutputType([GitHubRelease])]
    [CmdletBinding(DefaultParameterSetName = 'Latest')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'All')]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # Get all releases.
        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch] $All,

        # The name of the tag to get a release from.
        [Parameter(Mandatory, ParameterSetName = 'Tag')]
        [string] $Tag,

        # The unique identifier of the release.
        [Parameter(Mandatory, ParameterSetName = 'ID')]
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
        $params = @{
            Owner      = $Owner
            Repository = $Repository
            Context    = $Context
        }
        Write-Debug "ParameterSet: $($PSCmdlet.ParameterSetName)"
        switch ($PSCmdlet.ParameterSetName) {
            'All' {
                Get-GitHubReleaseAll @params -PerPage $PerPage
            }
            'Tag' {
                Get-GitHubReleaseByTagName @params -Tag $Tag
            }
            'ID' {
                Get-GitHubReleaseByID @params -ID $ID
            }
            'Latest' {
                Get-GitHubReleaseLatest @params
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
