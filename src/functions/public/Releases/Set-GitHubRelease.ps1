filter Update-GitHubRelease {
    <#
        .SYNOPSIS
        Update a release

        .DESCRIPTION
        Users with push access to the repository can edit a release.

        .EXAMPLE
        Update-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -ID '1234567' -Body 'Release notes'

        Updates the release with the ID '1234567' for the repository 'octocat/hello-world' with the body 'Release notes'.

        .NOTES
        [Update a release](https://docs.github.com/rest/releases/releases#update-a-release)
    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The unique identifier of the release.
        [Parameter(Mandatory)]
        [string] $ID,

        # The name of the tag.
        [Parameter()]
        [string] $Tag,

        # Specifies the commitish value that determines where the Git tag is created from.
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
        [Parameter()]
        [switch] $Draft,

        # Whether to identify the release as a prerelease.
        [Parameter()]
        [switch] $Prerelease,

        # If specified, a discussion of the specified category is created and linked to the release.
        # The value must be a category that already exists in the repository.
        # For more information, see [Managing categories for discussions in your repository](https://docs.github.com/discussions/managing-discussions-for-your-community/managing-categories-for-discussions-in-your-repository).
        [Parameter()]
        [string] $DiscussionCategoryName,

        # Specifies whether this release should be set as the latest release for the repository. Drafts and prereleases cannot be set as latest.
        # If not specified the latest release is determined based on the release creation date and higher semantic version.
        # If set to true, the release will be set as the latest release for the repository.
        # If set to false, the release will not be set as the latest release for the repository.
        [Parameter()]
        [switch] $Latest,

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
        $body = @{
            tag_name                 = $Tag
            target_commitish         = $Target
            name                     = $Name
            body                     = $Notes
            discussion_category_name = $DiscussionCategoryName
            make_latest              = $Latest
            draft                    = $Draft
            prerelease               = $Prerelease
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'PATCH'
            APIEndpoint = "/repos/$Owner/$Repository/releases/$ID"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("release with ID [$ID] in [$Owner/$Repository]", 'Update')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                [GitHubRelease]::new($_.Response, $Owner, $Repository, $Latest)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
