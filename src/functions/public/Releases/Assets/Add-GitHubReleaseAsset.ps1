﻿filter Add-GitHubReleaseAsset {
    <#
        .SYNOPSIS
        Upload a release asset

        .DESCRIPTION
        This endpoint makes use of [a Hypermedia relation](https://docs.github.com/rest/overview/resources-in-the-rest-api#hypermedia)
        to determine which URL to access. The endpoint you call to upload release assets is specific to your release. Use the
        `upload_url` returned in
        the response of the [Create a release endpoint](https://docs.github.com/rest/releases/releases#create-a-release) to upload
        a release asset.

        You need to use an HTTP client which supports [SNI](http://en.wikipedia.org/wiki/Server_Name_Indication) to make calls to
        this endpoint.

        Most libraries will set the required `Content-Length` header automatically. Use the required `Content-Type` header to provide
        the media type of the asset. For a list of media types, see
        [Media Types](https://www.iana.org/assignments/media-types/media-types.xhtml). For example:

        `application/zip`

        GitHub expects the asset data in its raw binary form, rather than JSON. You will send the raw binary content of the asset
        as the request body. Everything else about the endpoint is the same as the rest of the API. For example,
        you'll still need to pass your authentication to be able to upload an asset.

        When an upstream failure occurs, you will receive a `502 Bad Gateway` status. This may leave an empty asset with a state
        of `starter`. It can be safely deleted.

        **Notes:**
        * GitHub renames asset filenames that have special characters, non-alphanumeric characters, and leading or trailing periods.
        The "[List release assets](https://docs.github.com/rest/releases/assets#list-release-assets)"
        endpoint lists the renamed filenames. For more information and help, contact
        [GitHub Support](https://support.github.com/contact?tags=dotcom-rest-api).
        * To find the `release_id` query the
        [`GET /repos/{owner}/{repo}/releases/latest` endpoint](https://docs.github.com/rest/releases/releases#get-the-latest-release).
        * If you upload an asset with the same filename as another uploaded asset, you'll receive an error and must delete
        the old file before you can re-upload the new asset.

        .EXAMPLE
        Add-GitHubReleaseAsset -Owner 'octocat' -Repository 'hello-world' -ID '7654321' -FilePath 'C:\Users\octocat\Downloads\hello-world.zip'

        Gets the release assets for the release with the ID '1234567' for the repository 'octocat/hello-world'.

        .NOTES
        [Upload a release asset](https://docs.github.com/rest/releases/assets#upload-a-release-asset)
    #>
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The unique identifier of the release.
        [Parameter(Mandatory)]
        [Alias('release_id')]
        [string] $ID,

        #The name of the file asset.
        [Parameter()]
        [string] $Name,

        # An alternate short description of the asset. Used in place of the filename.
        [Parameter()]
        [string] $Label,

        # The content type of the asset.
        [Parameter()]
        [string] $ContentType,

        # The path to the asset file.
        [Parameter(Mandatory)]
        [alias('FullName')]
        [string] $FilePath,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        # If name is not provided, use the name of the file
        if (!$Name) {
            $Name = (Get-Item $FilePath).Name
        }

        # If label is not provided, use the name of the file
        if (!$Label) {
            $Label = (Get-Item $FilePath).Name
        }

        # If content type is not provided, use the file extension
        if (!$ContentType) {
            $ContentType = switch ((Get-Item $FilePath).Extension) {
                '.zip' { 'application/zip' }
                '.tar' { 'application/x-tar' }
                '.gz' { 'application/gzip' }
                '.bz2' { 'application/x-bzip2' }
                '.xz' { 'application/x-xz' }
                '.7z' { 'application/x-7z-compressed' }
                '.rar' { 'application/vnd.rar' }
                '.tar.gz' { 'application/gzip' }
                '.tgz' { 'application/gzip' }
                '.tar.bz2' { 'application/x-bzip2' }
                '.tar.xz' { 'application/x-xz' }
                '.tar.7z' { 'application/x-7z-compressed' }
                '.tar.rar' { 'application/vnd.rar' }
                '.png' { 'image/png' }
                '.json' { 'application/json' }
                '.txt' { 'text/plain' }
                '.md' { 'text/markdown' }
                '.html' { 'text/html' }
                default { 'application/octet-stream' }
            }
        }

        $release = Get-GitHubRelease -Owner $Owner -Repository $Repository -ID $ID
        $uploadURI = $release.upload_url -replace '{\?name,label}', "?name=$($Name)&label=$($Label)"

        $inputObject = @{
            Method         = 'POST'
            URI            = $uploadURI
            ContentType    = $ContentType
            UploadFilePath = $FilePath
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
