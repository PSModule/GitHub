filter Set-GitHubRelease {
    <#
        .SYNOPSIS
        Creates or updates a release.

        .DESCRIPTION
        The Set-GitHubRelease cmdlet creates a new GitHub release or updates an existing one for a specified tag.

        This function first checks if a release with the specified tag already exists:
        - If the release exists, it will update the existing release with the provided parameters
        - If the release doesn't exist, it will create a new release

        You can specify whether the release is a draft or prerelease, generate release notes automatically,
        link a discussion to the release, and set a release as the latest for the repository.

        When using the 'Latest' parameter, the release will be promoted from draft/prerelease status to a full release.

        .EXAMPLE
        Set-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0' -Target 'main' -Notes 'Release notes'

        Creates a new release with tag 'v1.0.0' targeting the 'main' branch.

        .EXAMPLE
        Set-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0' -Notes 'Updated release notes'

        Updates an existing release with tag 'v1.0.0' to have new release notes.

        .EXAMPLE
        Set-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0' -Draft

        Creates or updates a release as a draft release.

        .EXAMPLE
        Set-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0' -Prerelease

        Creates or updates a release as a prerelease.

        .EXAMPLE
        Set-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0' -Latest

        Sets the release with tag 'v1.0.0' as the latest release for the repository. If the release was a draft or prerelease,
        it will be promoted to a full release.

        .EXAMPLE
        Set-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0' -GenerateReleaseNotes

        Creates or updates a release with automatically generated release notes based on pull requests and commits.

        .EXAMPLE
        Get-GitHubRepository -Owner 'octocat' -Repository 'hello-world' | Set-GitHubRelease -Tag 'v1.0.0' -Notes 'Release notes'

        Creates or updates a release using pipeline input for the repository.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRelease

        .LINK
        https://psmodule.io/GitHub/Functions/Releases/Set-GitHubRelease/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSShouldProcess', '', Scope = 'Function',
        Justification = 'This check is performed in the private functions.'
    )]
    [OutputType([GitHubRelease])]
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
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Tag,

        # Specifies the reference value that determines where the Git tag is created from.
        # Can be any branch or commit SHA. Unused if the Git tag already exists.
        # API Default: the repository's default branch.
        [Parameter()]
        [string] $Target = 'main',

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
        [Parameter()]
        [string] $DiscussionCategoryName,

        # Whether to automatically generate the name and body for this release. If name is specified, the specified name will be used; otherwise,
        # a name will be automatically generated. If body is specified, the body will be pre-pended to the automatically generated notes.
        [Parameter()]
        [switch] $GenerateReleaseNotes,

        # Specifies whether this release should be set as the latest release for the repository. If the release is a draft or a prerelease, setting
        # this parameters will promote the release to a release, setting the draft and prerelease parameters to false.
        [Parameter(Mandatory, ParameterSetName = 'Set latest')]
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
        $scope = @{
            Owner      = $Owner
            Repository = $Repository
            Context    = $Context
        }

        $params = @{
            Tag                    = $Tag
            Target                 = $Target
            Name                   = $Name
            Notes                  = $Notes
            GenerateReleaseNotes   = [bool]$GenerateReleaseNotes
            DiscussionCategoryName = $DiscussionCategoryName
        }

        switch ($PSCmdlet.ParameterSetName) {
            'Set latest' {
                $params['Latest'] = [bool]$Latest
            }
            'Not latest' {
                $params['Draft'] = [bool]$Draft
                $params['Prerelease'] = [bool]$Prerelease
            }
        }

        $release = Get-GitHubRelease @scope -Tag $Tag
        if ($release) {
            $ID = $release.ID
            $params['ID'] = $ID
            Update-GitHubRelease @scope @params -Declare
        } else {
            New-GitHubRelease @scope @params
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
