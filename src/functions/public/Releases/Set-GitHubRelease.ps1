filter Set-GitHubRelease {
    <#
        .SYNOPSIS
        Creates or updates a release.

        .DESCRIPTION


        .EXAMPLE
        Set-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0' -Target 'main' -Notes 'Release notes'

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRelease

        .LINK
        https://psmodule.io/GitHub/Functions/Releases/Set-GitHubRelease/
    #>
    [OutputType([GitHubRelease])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
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
        [Parameter()]
        [switch] $Draft,

        # Whether to identify the release as a prerelease.
        [Parameter()]
        [switch] $Prerelease,

        # If specified, a discussion of the specified category is created and linked to the release.
        # The value must be a category that already exists in the repository.
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
            DiscussionCategoryName = $DiscussionCategoryName
            Latest                 = $PSBoundParameters.ContainsKey('Latest') ? [bool]$Latest : $null
            Draft                  = $PSBoundParameters.ContainsKey('Draft') ? [bool]$Draft : $null
            Prerelease             = $PSBoundParameters.ContainsKey('Prerelease') ? [bool]$Prerelease : $null
        }
        $params | Remove-HashtableEntry -NullOrEmptyValues

        if (Get-GitHubRelease @scope -Tag $Tag) {
            if ($PSBoundParameters.ContainsKey('GenerateReleaseNotes')) {
                $params['GenerateReleaseNotes'] = $GenerateReleaseNotes
            }
            $null = Update-GitHubRelease @scope @params
        } else {
            $null = New-GitHubRelease @scope @params
        }

        Get-GitHubRelease @scope -Tag $Tag
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
