﻿filter Get-GitHubReleaseByID {
    <#
        .SYNOPSIS
        Get a release

        .DESCRIPTION
        **Note:** This returns an `upload_url` key corresponding to the endpoint for uploading release assets.
        This key is a [hypermedia resource](https://docs.github.com/rest/overview/resources-in-the-rest-api#hypermedia).

        .EXAMPLE
        Get-GitHubReleaseById -Owner 'octocat' -Repo 'hello-world' -ID '1234567'

        Gets the release with the ID '1234567' for the repository 'hello-world' owned by 'octocat'.

        .NOTES
        https://docs.github.com/rest/releases/releases#get-a-release

    #>
    [CmdletBinding()]
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
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
