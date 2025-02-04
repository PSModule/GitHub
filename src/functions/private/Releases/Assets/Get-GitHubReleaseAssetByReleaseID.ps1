filter Get-GitHubReleaseAssetByReleaseID {
    <#
        .SYNOPSIS
        List release assets

        .DESCRIPTION
        List release assets

        .EXAMPLE
        Get-GitHubReleaseAssetByReleaseID -Owner 'octocat' -Repo 'hello-world' -ID '1234567'

        Gets the release assets for the release with the ID '1234567' for the repository 'octocat/hello-world'.

        .NOTES
        https://docs.github.com/rest/releases/assets#list-release-assets

    #>
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repo,

        # The unique identifier of the release.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ID'
        )]
        [Alias('release_id')]
        [string] $ID,

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
        $body = @{
            per_page = $PerPage
        }

        $inputObject = @{
            Method      = 'Get'
            APIEndpoint = "/repos/$Owner/$Repo/releases/$ID/assets"
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
    end {
        Write-Debug "[$stackPath] - End"
    }
}
