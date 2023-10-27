filter Remove-GitHubRelease {
    <#
        .SYNOPSIS
        Delete a release

        .DESCRIPTION
        Users with push access to the repository can delete a release.

        .EXAMPLE
        Remove-GitHubRelease -Owner 'octocat' -Repo 'hello-world' -ID '1234567'

        Deletes the release with the ID '1234567' for the repository 'octocat/hello-world'.

        .NOTES
        https://docs.github.com/rest/releases/releases#delete-a-release

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The unique identifier of the release.
        [Parameter(
            Mandatory
        )]
        [Alias('release_id')]
        [string] $ID
    )

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/releases/$ID"
        Method      = 'DELETE'
    }

    if ($PSCmdlet.ShouldProcess("Release with ID [$ID] in [$Owner/$Repo]", "Delete")) {
        (Invoke-GitHubAPI @inputObject).Response
    }

}
