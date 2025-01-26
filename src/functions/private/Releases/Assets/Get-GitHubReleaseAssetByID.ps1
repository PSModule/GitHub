filter Get-GitHubReleaseAssetByID {
    <#
        .SYNOPSIS
        Get a release asset

        .DESCRIPTION
        To download the asset's binary content, set the `Accept` header of the request to
        [`application/octet-stream`](https://docs.github.com/rest/overview/media-types).
        The API will either redirect the client to the location, or stream it directly if
        possible. API clients should handle both a `200` or `302` response.

        .EXAMPLE
        Get-GitHubReleaseAssetByID -Owner 'octocat' -Repo 'hello-world' -ID '1234567'

        Gets the release asset with the ID '1234567' for the repository 'octocat/hello-world'.

        .NOTES
        https://docs.github.com/rest/releases/assets#get-a-release-asset

    #>
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repo,

        # The unique identifier of the asset.
        [Parameter(Mandatory)]
        [Alias('asset_id')]
        [string] $ID,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner: [$Owner]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo: [$Repo]"
    }

    process {
        try {

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/repos/$Owner/$Repo/releases/assets/$ID"
                Method      = 'GET'
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
