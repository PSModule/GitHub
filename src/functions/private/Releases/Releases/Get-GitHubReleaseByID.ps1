filter Get-GitHubReleaseByID {
    <#
        .SYNOPSIS
        Get a release

        .DESCRIPTION
        **Note:** This returns an `upload_url` key corresponding to the endpoint for uploading release assets.
        This key is a [hypermedia resource](https://docs.github.com/rest/overview/resources-in-the-rest-api#hypermedia).

        .EXAMPLE
        Get-GitHubReleaseById -Owner 'octocat' -Repository 'hello-world' -ID '1234567'

        Gets the release with the ID '1234567' for the repository 'hello-world' owned by 'octocat'.

        .NOTES
        https://docs.github.com/rest/releases/releases#get-a-release

    #>
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
        [Alias('release_id')]
        [string] $ID,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [GitHubContext] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'Get'
            APIEndpoint = "/repos/$Owner/$Repository/releases/$ID"
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
