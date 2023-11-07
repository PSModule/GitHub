filter Get-GitHubReleaseLatest {
    <#
        .SYNOPSIS
        Get the latest release

        .DESCRIPTION
        View the latest published full release for the repository.
        The latest release is the most recent non-prerelease, non-draft release, sorted by the `created_at` attribute.
        The `created_at` attribute is the date of the commit used for the release, and not the date when the release was drafted or published.

        .EXAMPLE
        Get-GitHubReleaseLatest -Owner 'octocat' -Repo 'hello-world'

        Gets the latest releases for the repository 'hello-world' owned by 'octocat'.

        .NOTES
        https://docs.github.com/rest/releases/releases#get-the-latest-release

    #>
    [CmdletBinding()]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo)

    )

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/releases/latest"
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
