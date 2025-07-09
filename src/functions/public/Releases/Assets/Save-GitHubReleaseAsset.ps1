function Save-GitHubReleaseAsset {
    <#
        .SYNOPSIS
        Downloads a GitHub Release asset.

        .DESCRIPTION
        Downloads an asset from a repository release. The asset is downloaded as a file to the specified path
        or the current directory by default. Users must have read access to the repository. For private repositories,
        personal access tokens (classic) or OAuth tokens with the `repo` scope are required.

        .EXAMPLE
        Save-GitHubReleaseAsset -Owner 'octocat' -Repository 'Hello-World' -ID '123456' -Path 'C:\Assets'

        Output:
        ```powershell
        Directory: C:\Assets

        Mode                 LastWriteTime         Length Name
        ----                 -------------         ------ ----
        -a----        03/31/2025     12:00       4194304 asset-123456.zip
        ```

        Downloads release asset ID '123456' from the 'Hello-World' repository owned by 'octocat' to the specified path.

        .EXAMPLE
        Save-GitHubReleaseAsset -Owner 'octocat' -Repository 'Hello-World' -Tag 'v1.0.0' -Name 'binary.zip' -Path 'C:\Assets\app' -Expand -Force

        Output:
        ```powershell
        Directory: C:\Assets\app

        Mode                 LastWriteTime         Length Name
        ----                 -------------         ------ ----
        -a----        03/31/2025     12:00          5120 config.json
        -a----        03/31/2025     12:00       4194304 application.exe
        ```

        Downloads asset named 'binary.zip' from the release tagged as 'v1.0.0' in the 'Hello-World' repository owned by 'octocat'
        to the specified path, overwriting existing files during download and extraction.

        .EXAMPLE
        $params = @{
            Owner         = 'octocat'
            Repository    = 'Hello-World'
            ID            = '123456'
            Tag           = 'v1.0.0'
            Name          = 'binary.zip'
        }
        Get-GitHubReleaseAsset @params | Save-GitHubReleaseAsset -Path 'C:\Assets' -Expand -Force

        Pipes a release asset object directly to the Save-GitHubReleaseAsset function, which downloads and extracts it.

        .INPUTS
        GitHubReleaseAsset

        .OUTPUTS
        System.IO.FileSystemInfo[]

        .NOTES
        Contains the extracted file or folder information from the downloaded asset.
        This output can include directories or files depending on the asset content.

        .LINK
        https://psmodule.io/GitHub/Functions/Releases/Assets/Save-GitHubReleaseAsset/
    #>
    [OutputType([System.IO.FileSystemInfo[]])]
    [CmdletBinding(DefaultParameterSetName = 'By Asset ID')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'By Asset ID')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'By Release ID and Asset Name')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'By Tag and Asset Name')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'By Asset ID')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'By Release ID and Asset Name')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'By Tag and Asset Name')]
        [string] $Repository,

        # The unique identifier of the asset.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'By Asset ID')]
        [string] $ID,

        # The unique identifier of the release.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'By Release ID and Asset Name')]
        [string] $ReleaseID,

        # The tag name of the release.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'By Tag and Asset Name')]
        [string] $Tag,

        # The name of the asset to download.
        [Parameter(Mandatory, ParameterSetName = 'By Release ID and Asset Name')]
        [Parameter(Mandatory, ParameterSetName = 'By Tag and Asset Name')]
        [string] $Name,

        # The GitHubReleaseAsset object containing the information about the asset to download.
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'By Asset Object')]
        [GitHubReleaseAsset] $ReleaseAssetObject,

        # Path to the file or folder for the download. Accepts relative or absolute paths.
        [Parameter()]
        [string] $Path = $PWD.Path,

        # When specified, the ZIP file is extracted to the same directory it was downloaded to.
        [Parameter()]
        [Alias('Extract')]
        [switch] $Expand,

        # When specified, overwrites existing files during download and extraction.
        [Parameter()]
        [switch] $Force,

        # When specified, the downloaded file or the folder where the ZIP file was extracted to is returned.
        [Parameter()]
        [switch] $PassThru,

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
        $asset = $null

        switch ($PSCmdlet.ParameterSetName) {
            'By Asset ID' {
                $asset = Get-GitHubReleaseAsset -Owner $Owner -Repository $Repository -ID $ID -Context $Context
            }
            'By Release ID and Asset Name' {
                $asset = Get-GitHubReleaseAsset -Owner $Owner -Repository $Repository -ReleaseID $ReleaseID -Name $Name -Context $Context
            }
            'By Tag and Asset Name' {
                $asset = Get-GitHubReleaseAsset -Owner $Owner -Repository $Repository -Tag $Tag -Name $Name -Context $Context
            }
            'By Asset Object' {
                $asset = $ReleaseAssetObject
            }
        }

        if (-not $asset) {
            throw 'Release asset not found. Please verify the parameters provided.'
        }

        # Now download the asset
        $apiParams = @{
            Method  = 'GET'
            Uri     = $asset.Url
            Context = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            $itemType = $Path.EndsWith('.zip') ? 'File' : 'Directory'
            $isAbsolute = [System.IO.Path]::IsPathRooted($Path)
            $filename = $asset.Name

            Write-Debug "Path:        [$Path]"
            Write-Debug "Type:        [$itemType]"
            Write-Debug "Is absolute: [$isAbsolute]"
            Write-Debug "Filename:    [$filename]"

            if ($itemType -eq 'Directory') {
                $Path = Join-Path -Path $Path -ChildPath $filename
            }

            $folderPath = [System.IO.Path]::GetDirectoryName($Path)
            $folder = New-Item -Path $folderPath -ItemType Directory -Force
            Write-Debug "Resolved final download path: [$Path]"
            [System.IO.File]::WriteAllBytes($Path, $_.Response)

            # Check if we need to expand the downloaded file
            if ($Expand -and $filename -match '\.(zip|tar|gz|bz2|xz|7z|rar)$') {
                Write-Debug "Expanding asset to [$folder]"
                Expand-Archive -LiteralPath $Path -DestinationPath $folder -Force:$Force
                Write-Debug "Removing ZIP file [$Path]"
                Remove-Item -LiteralPath $Path -Force
                if ($PassThru) {
                    return $folder
                }
            }
            if ($PassThru) {
                return Get-Item -Path $Path
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
