filter Get-GitHubReleaseByID {
    <#
        .SYNOPSIS
        Get a release

        .DESCRIPTION
        **Note:** This returns an `upload_url` key corresponding to the endpoint for uploading release assets.
        This key is a [hypermedia resource](https://docs.github.com/rest/overview/resources-in-the-rest-api#hypermedia).

        .EXAMPLE
        ```powershell
        Get-GitHubReleaseById -Owner 'octocat' -Repository 'hello-world' -ID '1234567'
        ```

        Gets the release with the ID '1234567' for the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRelease

        .NOTES
        [Get a release](https://docs.github.com/rest/releases/releases#get-a-release)
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

        # The unique identifier of the release.
        [Parameter(Mandatory)]
        [string] $ID,

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

        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/releases/$ID"
            Context     = $Context
        }

        try {
            Invoke-GitHubAPI @apiParams | ForEach-Object {
                $isLatest = $_.Response.id -eq $latest.id
                [GitHubRelease]::new($_.Response, $Owner, $Repository, $isLatest)
            }
        } catch { return }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
