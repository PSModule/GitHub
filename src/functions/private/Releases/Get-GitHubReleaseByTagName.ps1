filter Get-GitHubReleaseByTagName {
    <#
        .SYNOPSIS
        Get a release by tag name

        .DESCRIPTION
        Get a published release with the specified tag.

        .EXAMPLE
        Get-GitHubReleaseByTagName -Owner 'octocat' -Repository 'hello-world' -Tag 'v1.0.0'

        Gets the release with the tag 'v1.0.0' for the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRelease

        .LINK
        [Get a release by tag name](https://docs.github.com/rest/releases/releases#get-a-release-by-tag-name)
    #>
    [OutputType([GitHubRelease])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The name of the tag to get a release from.
        [Parameter(Mandatory)]
        [string] $Tag,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $latest = Get-GitHubReleaseLatest -Owner $Owner -Repository $Repository -Context $Context

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/releases/tags/$Tag"
            Context     = $Context
        }

        try {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                $isLatest = $_.Response.id -eq $latest.id
                [GitHubRelease]::new($_.Response, $isLatest)
            }
        } catch { return }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
