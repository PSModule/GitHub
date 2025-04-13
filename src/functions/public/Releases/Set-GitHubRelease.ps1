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
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Not latest')]
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
        [Parameter(ParameterSetName = 'Not latest')]
        [switch] $Draft,

        # Whether to identify the release as a prerelease.
        [Parameter(ParameterSetName = 'Not latest')]
        [switch] $Prerelease,

        # If specified, a discussion of the specified category is created and linked to the release.
        # The value must be a category that already exists in the repository.
        [Parameter()]
        [string] $DiscussionCategoryName,

        # Specifies whether this release should be set as the latest release for the repository. If the release is a draft or a prerelease, setting
        # this parameters will promote the release to a release, setting the draft and prerelease parameters to false.
        [Parameter(Mandatory, ParameterSetName = 'Set latest')]
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
            Update-GitHubRelease @scope @params
        } else {
            New-GitHubRelease @scope @params
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
