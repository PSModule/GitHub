filter Add-GitHubReleaseAsset {
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
        Add-GitHubReleaseAsset -Owner 'octocat' -Repository 'hello-world' -ID '7654321' -Path 'C:\Users\octocat\Downloads\hello-world.zip'

        Gets the release assets for the release with the ID '1234567' for the repository 'octocat/hello-world'.

        .EXAMPLE
        Add-GitHubReleaseAsset -Owner 'octocat' -Repository 'hello-world' -ID '7654321' -Path 'C:\Users\octocat\Projects\MyApp'

        Automatically creates a ZIP file from the contents of the MyApp directory and uploads it as a release asset.

        .INPUTS
        GitHubRelease

        .OUTPUTS
        GitHubReleaseAsset

        .LINK
        https://psmodule.io/GitHub/Functions/Releases/Assets/Add-GitHubReleaseAsset/

        .NOTES
        [Upload a release asset](https://docs.github.com/rest/releases/assets#upload-a-release-asset)
    #>
    [OutputType([GitHubReleaseAsset])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The name of the tag to get a release from.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Tag,

        #The name of the file asset.
        [Parameter()]
        [string] $Name,

        # An alternate short description of the asset. Used in place of the filename.
        [Parameter()]
        [string] $Label,

        # The path to the asset file.
        [Parameter(Mandatory)]
        [alias('FullName')]
        [string] $Path,

        # The 'Content-Type' for the payload.
        [Parameter()]
        [string] $ContentType,

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
        try {
            $item = Get-Item $Path
            $isDirectory = $item.PSIsContainer
        } catch {
            throw "Error accessing the path: $_"
        }
        $fileToUpload = $Path
        # If the path is a directory, create a zip file from the contents of the folder
        if ($isDirectory) {
            Write-Verbose 'Path is a directory. Zipping contents...'
            $dirName = $item.Name
            $TempFilePath = "$dirName.zip"

            Write-Verbose "Creating temporary zip file: $TempFilePath"
            try {
                Get-ChildItem -Path $Path | Compress-Archive -DestinationPath $TempFilePath -ErrorAction Stop -Force
                $fileToUpload = $TempFilePath
            } catch {
                Remove-Item -Path $TempFilePath -Force -ErrorAction SilentlyContinue
            }
        }
        if (!$Name) {
            $Name = $item.Name
        }
        if (!$Label) {
            $Label = $item.Name
        }

        if (!$ContentType) {
            $ContentType = switch ((Get-Item $fileToUpload).Extension) {
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

        $release = Get-GitHubReleaseByTagName -Owner $Owner -Repository $Repository -Tag $Tag -Context $Context

        $body = @{
            name  = $Name
            label = $Label
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $urlParams = @{
            BaseUri = "https://uploads.$($Context.HostName)"
            Path    = "/repos/$Owner/$Repository/releases/$($release.id)/assets"
            Query   = $body
        }
        $uploadUrl = New-Uri @urlParams

        $apiParams = @{
            Method         = 'POST'
            Uri            = $uploadUrl
            ContentType    = $ContentType
            UploadFilePath = $fileToUpload
            Context        = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            [GitHubReleaseAsset]($_.Response)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }

    clean {
        if ($isDirectory) {
            Write-Verbose "Cleaning up temporary zip file: $TempFilePath"
            Remove-Item -Path $TempFilePath -Force -ErrorAction SilentlyContinue
        }
    }
}
