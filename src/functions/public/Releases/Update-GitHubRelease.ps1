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
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The unique identifier of the release.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
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

        # Specifies whether this release should be set as the latest release for the repository. If the release is a draft or a prerelease, setting
        # this parameters will promote the release to a release, setting the draft and prerelease parameters to false.
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
        if ($Latest) {
            $Draft = $false
            $Prerelease = $false
        }

        $body = @{
            tag_name                 = $Tag
            target_commitish         = $Target
            name                     = $Name
            body                     = $Notes
            discussion_category_name = $DiscussionCategoryName
            make_latest              = $PSBoundParameters.ContainsKey('Latest') ? [bool]$Latest : $null
            draft                    = $PSBoundParameters.ContainsKey('Draft') ? [bool]$Draft : $null
            prerelease               = $PSBoundParameters.ContainsKey('Prerelease') ? [bool]$Prerelease : $null
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'PATCH'
            APIEndpoint = "/repos/$Owner/$Repository/releases/$ID"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("release with ID [$ID] in [$Owner/$Repository]", 'Update')) {
            $null = Invoke-GitHubAPI @inputObject
        }
        Get-GitHubReleaseByID -Owner $Owner -Repository $Repository -ID $ID -Context $Context
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
