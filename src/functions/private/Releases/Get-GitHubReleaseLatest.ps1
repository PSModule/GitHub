filter Get-GitHubReleaseLatest {
    <#
        .SYNOPSIS
        Get the latest release

        .DESCRIPTION
        View the latest published full release for the repository.
        The latest release is the most recent non-prerelease, non-draft release, sorted by the `created_at` attribute.
        The `created_at` attribute is the date of the commit used for the release, and not the date when the release was drafted or published.

        .EXAMPLE
        Get-GitHubReleaseLatest -Owner 'octocat' -Repository 'hello-world'

        Gets the latest releases for the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRelease

        .LINK
        [Get the latest release](https://docs.github.com/rest/releases/releases#get-the-latest-release)
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
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/releases/latest"
            Context     = $Context
        }

        try {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                [GitHubRelease]::new($_.Response, $true)
            }
        } catch { return }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
