filter New-GitHubRelease {
    <#
        .SYNOPSIS
        Create a release

        .DESCRIPTION
        Users with push access to the repository can create a release.
        This endpoint triggers [notifications](https://docs.github.com/github/managing-subscriptions-and-notifications-on-github/about-notifications).
        Creating content too quickly using this endpoint may result in secondary rate limiting.
        See "[Secondary rate limits](https://docs.github.com/rest/overview/resources-in-the-rest-api#secondary-rate-limits)"
        and "[Dealing with secondary rate limits](https://docs.github.com/rest/guides/best-practices-for-integrators#dealing-with-secondary-rate-limits)" for details.

        .EXAMPLE
        New-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0' -Target 'main' -Notes 'Release notes'

        Creates a release for the repository 'octocat/hello-world' on the 'main' branch with the tag 'v1.0.0'.

        .EXAMPLE
        New-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v0.9.0' -Name 'Beta Release' -Draft -Prerelease

        Creates a draft prerelease for the repository 'octocat/hello-world' with the tag 'v0.9.0' using the default target branch ('main').

        .EXAMPLE
        New-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v2.0.0' -Latest

        Creates a release for the repository 'octocat/hello-world' with the tag 'v2.0.0' and marks it as the latest release.
        Note that when using -Latest, you cannot use -Draft or -Prerelease as they are mutually exclusive.

        .EXAMPLE
        New-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.1.0' -GenerateReleaseNotes

        Creates a release for the repository 'octocat/hello-world' with the tag 'v1.1.0' and automatically generates release notes based on commits since the previous release.

        .EXAMPLE
        New-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.2.0' -DiscussionCategoryName 'Announcements' -Notes 'Major update with new features'

        Creates a release for the repository 'octocat/hello-world' with the tag 'v1.2.0' and creates a discussion in the 'Announcements' category linked to this release.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRelease

        .LINK
        https://psmodule.io/GitHub/Functions/Releases/New-GitHubRelease/

        .NOTES
        [Create a release](https://docs.github.com/rest/releases/releases#create-a-release)
    #>
    [OutputType([GitHubRelease])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Not latest')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The name of the tag.
        [Parameter(Mandatory)]
        [string] $Tag,

        # Specifies the reference value that determines where the Git tag is created from.
        # Can be any branch or commit SHA. Unused if the Git tag already exists.
        # API Default: the repository's default branch.
        [Parameter()]
        [string] $Target,

        # The name of the release.
        [Parameter()]
        [string] $Name,

        # Text describing the contents of the tag.
        [Parameter()]
        [string] $Notes,

        # Whether the release is a draft.
        [Parameter(ParameterSetName = 'Not latest')]
        [switch] $Draft,

        # Whether to identify the release as a prerelease.
        [Parameter(ParameterSetName = 'Not latest')]
        [switch] $Prerelease,

        # If specified, a discussion of the specified category is created and linked to the release.
        # The value must be a category that already exists in the repository.
        # For more information, see [Managing categories for discussions in your repository](https://docs.github.com/discussions/managing-discussions-for-your-community/managing-categories-for-discussions-in-your-repository).
        [Parameter()]
        [string] $DiscussionCategoryName,

        # Whether to automatically generate the name and body for this release. If name is specified, the specified name will be used; otherwise,
        # a name will be automatically generated. If body is specified, the body will be pre-pended to the automatically generated notes.
        [Parameter()]
        [switch] $GenerateReleaseNotes,

        # Specifies whether this release should be set as the latest release for the repository. Drafts and prereleases cannot be set as latest.
        # If not specified the latest release is determined based on the release creation date and higher semantic version.
        # If set to true, the release will be set as the latest release for the repository.
        # If set to false, the release will not be set as the latest release for the repository.
        [Parameter(ParameterSetName = 'Set latest')]
        [switch] $Latest,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            tag_name                 = $Tag
            target_commitish         = $Target
            name                     = $Name
            body                     = $Notes
            discussion_category_name = $DiscussionCategoryName
            generate_release_notes   = [bool]$GenerateReleaseNotes
            make_latest              = ([bool]$Latest).ToString().ToLower()
            draft                    = [bool]$Draft
            prerelease               = [bool]$Prerelease
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = "/repos/$Owner/$Repository/releases"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("$Owner/$Repository", 'Create a release')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                [GitHubRelease]::new($_.Response , $Owner, $Repository, $Latest)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
