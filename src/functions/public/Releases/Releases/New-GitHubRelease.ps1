﻿filter New-GitHubRelease {
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
        New-GitHubRelease -Owner 'octocat' -Repo 'hello-world' -TagName 'v1.0.0' -TargetCommitish 'main' -Body 'Release notes'

        Creates a release for the repository 'octocat/hello-world' with the tag 'v1.0.0' and the target commitish 'main'.

        .NOTES
        [Create a release](https://docs.github.com/rest/releases/releases#create-a-release)
    #>
    #SkipTest:FunctionTest:Will add a test for this function in a future PR
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # The name of the tag.
        [Parameter(Mandatory)]
        [Alias('tag_name')]
        [string] $TagName,

        # Specifies the commitish value that determines where the Git tag is created from.
        # Can be any branch or commit SHA. Unused if the Git tag already exists.
        # API Default: the repository's default branch.
        [Parameter()]
        [Alias('target_commitish')]
        [string] $TargetCommitish = 'main',

        # The name of the release.
        [Parameter()]
        [string] $Name,

        # Text describing the contents of the tag.
        [Parameter()]
        [string] $Body,

        # Whether the release is a draft.
        [Parameter()]
        [switch] $Draft,

        # Whether to identify the release as a prerelease.
        [Parameter()]
        [switch] $Prerelease,

        # If specified, a discussion of the specified category is created and linked to the release.
        # The value must be a category that already exists in the repository.
        # For more information, see [Managing categories for discussions in your repository](https://docs.github.com/discussions/managing-discussions-for-your-community/managing-categories-for-discussions-in-your-repository).
        [Parameter()]
        [Alias('discussion_category_name')]
        [string] $DiscussionCategoryName,

        # Whether to automatically generate the name and body for this release. If name is specified, the specified name will be used; otherwise,a name will be automatically generated. If body is specified, the body will be pre-pended to the automatically generated notes.
        [Parameter()]
        [Alias('generate_release_notes')]
        [switch] $GenerateReleaseNotes,

        # Specifies whether this release should be set as the latest release for the repository. Drafts and prereleases cannot be set as latest. Defaults to true for newly published releases. legacy specifies that the latest release should be determined based on the release creation date and higher semantic version.
        [Parameter()]
        [Alias('make_latest')]
        [ValidateSet('true', 'false', 'legacy')]
        [string] $MakeLatest = 'true',

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

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner: [$Owner]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo: [$Repo]"
    }

    process {
        try {
            $requestBody = @{
                tag_name                 = $TagName
                target_commitish         = $TargetCommitish
                name                     = $Name
                body                     = $Body
                discussion_category_name = $DiscussionCategoryName
                make_latest              = $MakeLatest
                generate_release_notes   = $GenerateReleaseNotes
                draft                    = $Draft
                prerelease               = $Prerelease
            }
            $requestBody | Remove-HashtableEntry -NullOrEmptyValues

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/repos/$Owner/$Repo/releases"
                Method      = 'POST'
                Body        = $requestBody
            }

            if ($PSCmdlet.ShouldProcess("$Owner/$Repo", 'Create a release')) {
                Invoke-GitHubAPI @inputObject | ForEach-Object {
                    Write-Output $_.Response
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
