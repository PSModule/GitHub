filter Get-GitHubReleaseByTagName {
    <#
        .SYNOPSIS
        Get a release by tag name

        .DESCRIPTION
        Get a published release with the specified tag.

        .EXAMPLE
        Get-GitHubReleaseByTagName -Owner 'octocat' -Repo 'hello-world' -Tag 'v1.0.0'

        Gets the release with the tag 'v1.0.0' for the repository 'hello-world' owned by 'octocat'.

        .NOTES
        https://docs.github.com/rest/releases/releases#get-a-release-by-tag-name

    #>
    [CmdletBinding()]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The name of the tag to get a release from.
        [Parameter(
            Mandatory
        )]
        [Alias('tag_name')]
        [string] $Tag
    )

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/releases/tags/$Tag"
        Method      = 'GET'
    }

    (Invoke-GitHubAPI @inputObject).Response

}
