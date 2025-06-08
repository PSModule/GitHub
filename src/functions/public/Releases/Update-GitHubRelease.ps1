filter Update-GitHubRelease {
    <#
        .SYNOPSIS
        Update a release

        .DESCRIPTION
        Users with push access to the repository can edit a release.

        You must specify either the ID or Tag parameter to identify the release to update.
        The function also accepts GitHubRelease objects through the pipeline.

        .EXAMPLE
        Update-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -ID '1234567' -Notes 'Release notes'

        Updates the release with the ID '1234567' for the repository 'octocat/hello-world' with the note 'Release notes'.

        .EXAMPLE
        Update-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0' -Name 'Release v1.0' -Notes 'Stable release'

        Updates the release with the tag 'v1.0' for the repository 'octocat/hello-world' with a new name and notes.

        .EXAMPLE
        Get-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0' |
            Update-GitHubRelease -Draft:$false -Prerelease

        Gets a release by tag and updates it to be a prerelease (not a draft).

        .EXAMPLE
        Update-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0' -Latest -GenerateReleaseNotes

        Updates the release with tag 'v1.0' to be the latest release and automatically generates release notes.

        .INPUTS
        GitHubRelease

        .OUTPUTS
        GitHubRelease

        .NOTES
        [Update a release](https://docs.github.com/rest/releases/releases#update-a-release)

        .LINK
        https://psmodule.io/GitHub/Functions/Releases/Update-GitHubRelease
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

        # The unique identifier of the release.
        [Parameter()]
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
        [Parameter(ParameterSetName = 'Not latest')]
        [System.Nullable[switch]] $Draft,

        # Whether to identify the release as a prerelease.
        [Parameter(ParameterSetName = 'Not latest')]
        [System.Nullable[switch]] $Prerelease,

        # If specified, a discussion of the specified category is created and linked to the release.
        # The value must be a category that already exists in the repository.
        # For more information, see [Managing categories for discussions in your repository](https://docs.github.com/discussions/managing-discussions-for-your-community/managing-categories-for-discussions-in-your-repository).
        [Parameter()]
        [string] $DiscussionCategoryName,

        # Whether to automatically generate the name and body for this release. If name is specified, the specified name will be used; otherwise,
        # a name will be automatically generated. If body is specified, the body will be pre-pended to the automatically generated notes.
        [Parameter()]
        [switch] $GenerateReleaseNotes,

        # Specifies whether this release should be set as the latest release for the repository. If the release is a draft or a prerelease, setting
        # this parameters will promote the release to a release, setting the draft and prerelease parameters to false.
        [Parameter(Mandatory, ParameterSetName = 'Set latest')]
        [System.Nullable[switch]] $Latest,

        # Takes all parameters and updates the release with the provided _AND_ the default values of the non-provided parameters.
        # Used for Set-GitHubRelease.
        [Parameter()]
        [switch] $Declare,

        # The release to update
        [Parameter(ValueFromPipeline)]
        [GitHubRelease] $ReleaseObject,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context -Anonymous $Anonymous
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $ID = $ReleaseObject.ID

        if (-not $ID -and -not $Tag) {
            throw 'You must specify either the ID or the Tag parameter.'
        }

        if ($GenerateReleaseNotes) {
            $generated = New-GitHubReleaseNote -Owner $Owner -Repository $Repository -Tag $Tag -Context $Context
            $Name = -not [string]::IsNullOrEmpty($Name) ? $Name : $generated.Name
            $Notes = -not [string]::IsNullOrEmpty($Notes) ? $Notes, $generated.Notes -join "`n" : $generated.Notes
        }

        $body = @{
            tag_name         = $Tag
            target_commitish = $Target
            name             = $Name
            body             = $Notes
        }

        if ([string]::IsNullOrEmpty($ID) -and -not [string]::IsNullOrEmpty($Tag)) {
            $release = if ($ReleaseObject) {
                $ReleaseObject
            } else {
                Get-GitHubRelease -Owner $Owner -Repository $Repository -Tag $Tag -Context $Context
            }
            if (-not $release) {
                throw "Release with tag [$Tag] not found in [$Owner/$Repository]."
            }
            $ID = $release.ID
            $body.Remove('tag_name')
        }

        $repo = Get-GitHubRepositoryByName -Owner $Owner -Name $Repository -Context $Context -Property HasDiscussions
        if ($repo.HasDiscussions -and $PSBoundParameters.ContainsKey('DiscussionCategoryName') -and -not [string]::IsNullOrEmpty($DiscussionCategoryName)) {
            $body['discussion_category_name'] = $DiscussionCategoryName
        }
        if (-not $Declare) {
            $body | Remove-HashtableEntry -NullOrEmptyValues
        }

        if ($Latest) {
            $body['make_latest'] = [bool]$Latest.ToString().ToLower()
            $body['prerelease'] = $false
            $body['draft'] = $false
        }
        if ($Draft -or $Prerelease) {
            $body['make_latest'] = $false
            $body['prerelease'] = [bool]$Prerelease
            $body['draft'] = [bool]$Draft
        }

        $inputObject = @{
            Method      = 'PATCH'
            APIEndpoint = "/repos/$Owner/$Repository/releases/$ID"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("release with ID [$ID] in [$Owner/$Repository]", 'Update')) {
            $resultLatest = $PSBoundParameters.ContainsKey('Latest') ? $Latest : $release.IsLatest
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                [GitHubRelease]::new($_.Response , $Owner, $Repository, $resultLatest)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
