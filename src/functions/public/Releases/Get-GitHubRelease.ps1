filter Get-GitHubRelease {
    <#
        .SYNOPSIS
        Retrieves GitHub release information for a repository.

        .DESCRIPTION
        This returns a list of releases, which does not include regular Git tags that have not been associated with a release.
        To get a list of Git tags, use the [Repository Tags API](https://docs.github.com/rest/repos/repos#list-repository-tags).
        Information about published releases are available to everyone. Only users with push access will receive listings for draft releases.

        .EXAMPLE
        Get-GitHubRelease -Owner 'octocat' -Repository 'hello-world'

        Gets the latest release for the repository 'hello-world' owned by 'octocat'.

        .EXAMPLE
        Get-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -AllVersions

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
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSReviewUnusedParameter', 'AllVersions',
        Justification = 'Using the ParameterSetName to determine the context of the command.'
    )]
    [OutputType([GitHubRelease])]
    [CmdletBinding(DefaultParameterSetName = 'Latest')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # Get all releases instead of just the latest.
        [Parameter(Mandatory, ParameterSetName = 'AllVersions')]
        [switch] $AllVersions,

        # The name of the tag to get a release from.
        [Parameter(Mandatory, ParameterSetName = 'Tag')]
        [string] $Tag,

        # The unique identifier of the release.
        [Parameter(Mandatory, ParameterSetName = 'ID')]
        [string] $ID,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'AllVersions')]
        [System.Nullable[int]] $PerPage,

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
            'AllVersions' {
                Get-GitHubReleaseAll @params -PerPage $PerPage
            }
            'Tag' {
                $release = Get-GitHubReleaseByTagName @params -Tag $Tag
                if ($release) {
                    $release
                } else {
                    Get-GithubReleaseAll @params -PerPage $PerPage | Where-Object { $_.Tag -eq $Tag }
                }
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
