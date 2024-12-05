filter Remove-GitHubReleaseAsset {
    <#
        .SYNOPSIS
        Delete a release asset

        .DESCRIPTION
        Delete a release asset

        .EXAMPLE
        Remove-GitHubReleaseAsset -Owner 'octocat' -Repo 'hello-world' -ID '1234567'

        Deletes the release asset with the ID '1234567' for the repository 'octocat/hello-world'.

        .NOTES
        [Delete a release asset](https://docs.github.com/rest/releases/assets#delete-a-release-asset)

    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # The unique identifier of the asset.
        [Parameter(Mandatory)]
        [Alias('asset_id')]
        [string] $ID,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    if ([string]::IsNullOrEmpty($Owner)) {
        $Owner = $Context.Owner
    }
    Write-Debug "Owner : [$($Context.Owner)]"

    if ([string]::IsNullOrEmpty($Repo)) {
        $Repo = $Context.Repo
    }
    Write-Debug "Repo : [$($Context.Repo)]"

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/repos/$Owner/$Repo/releases/assets/$ID"
        Method      = 'DELETE'
    }

    if ($PSCmdlet.ShouldProcess("Asset with ID [$ID] in [$Owner/$Repo]", 'Delete')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

}
