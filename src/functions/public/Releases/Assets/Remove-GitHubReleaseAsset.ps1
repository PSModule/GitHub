filter Remove-GitHubReleaseAsset {
    <#
        .SYNOPSIS
        Delete a release asset

        .DESCRIPTION
        Delete a release asset

        .EXAMPLE
        Remove-GitHubReleaseAsset -Owner 'octocat' -Repository 'hello-world' -ID '1234567'

        Deletes the release asset with the ID '1234567' for the repository 'octocat/hello-world'.

        .INPUTS
        GitHubReleaseAsset

        .LINK
        https://psmodule.io/GitHub/Functions/Releases/Assets/Remove-GitHubReleaseAsset

        .NOTES
        [Delete a release asset](https://docs.github.com/rest/releases/assets#delete-a-release-asset)
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The unique identifier of the asset.
        [Parameter(Mandatory)]
        [string] $ID,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $apiParams = @{
            Method      = 'DELETE'
            APIEndpoint = "/repos/$Owner/$Repository/releases/assets/$ID"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Asset with ID [$ID] in [$Owner/$Repository]", 'DELETE')) {
            $null = Invoke-GitHubAPI @apiParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
