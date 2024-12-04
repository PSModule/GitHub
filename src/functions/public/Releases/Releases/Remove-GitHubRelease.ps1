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
        [Delete a release](https://docs.github.com/rest/releases/releases#delete-a-release)

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # The unique identifier of the release.
        [Parameter(
            Mandatory
        )]
        [Alias('release_id')]
        [string] $ID,

        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $contextObj = Get-GitHubContext -Context $Context
    if (-not $contextObj) {
        throw 'Log in using Connect-GitHub before running this command.'
    }
    Write-Debug "Context: [$Context]"

    if ([string]::IsNullOrEmpty($Owner)) {
        $Owner = $contextObj.Owner
    }
    Write-Debug "Owner : [$($contextObj.Owner)]"

    if ([string]::IsNullOrEmpty($Repo)) {
        $Repo = $contextObj.Repo
    }
    Write-Debug "Repo : [$($contextObj.Repo)]"

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/repos/$Owner/$Repo/releases/$ID"
        Method      = 'DELETE'
    }

    if ($PSCmdlet.ShouldProcess("Release with ID [$ID] in [$Owner/$Repo]", 'Delete')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

}
