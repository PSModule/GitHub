filter Get-GitHubReleaseAll {
    <#
        .SYNOPSIS
        List releases

        .DESCRIPTION
        This returns a list of releases, which does not include regular Git tags that have not been associated with a release.
        To get a list of Git tags, use the [Repository Tags API](https://docs.github.com/rest/repos/repos#list-repository-tags).
        Information about published releases are available to everyone. Only users with push access will receive listings for draft releases.

        .EXAMPLE
        Get-GitHubReleaseAll -Owner 'octocat' -Repository 'hello-world'

        Gets all the releases for the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRelease

        .LINK
        [List releases](https://docs.github.com/rest/releases/releases#list-releases)
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

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

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
            APIEndpoint = "/repos/$Owner/$Repository/releases"
            Body        = $body
            PerPage     = $PerPage
            Context     = $Context
        }

        try {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                $_.Response | ForEach-Object {
                    $isLatest = $_.id -eq $latest.id
                    [GitHubRelease]::new($_, $isLatest)
                }
            }
        } catch { return }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
