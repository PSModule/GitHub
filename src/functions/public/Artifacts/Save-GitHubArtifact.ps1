function Save-GitHubArtifact {
    <#
        .SYNOPSIS
        Downloads a GitHub Actions artifact from a workflow run.

        .DESCRIPTION
        Retrieves a specific artifact associated with a workflow run in the specified GitHub repository.
        The artifact is downloaded as a ZIP file to the specified path or the current directory by default.
        Users must have read access to the repository. For private repositories, personal access tokens (classic)
        or OAuth tokens with the `repo` scope are required.

        .EXAMPLE
        Save-GitHubArtifact -Owner 'octocat' -Repository 'Hello-World' -ID '123456' -Path 'C:\Artifacts'

        Output:
        ```powershell
        Directory: C:\Artifacts

        Mode                 LastWriteTime         Length Name
        ----                 -------------         ------ ----
        d-----        03/31/2025     12:00                artifact-123456.zip
        ```

        Downloads artifact ID 123456 from the 'Hello-World' repository owned by 'octocat' to the specified path.

        .INPUTS
        GitHubArtifact

        .OUTPUTS
        System.IO.FileSystemInfo[]

        .NOTES
        Contains the extracted file or folder information from the downloaded artifact.
        This output can include directories or files depending on the artifact content.

        .LINK
        [Get an artifact](https://docs.github.com/rest/actions/artifacts#get-an-artifact)
    #>
    [OutputType([System.IO.FileSystemInfo[]])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The unique identifier of the artifact.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('ArtifactID', 'DatabaseID')]
        [string] $ID,

        # Path to the file or folder for the download. Accepts relative or absolute paths.
        [Parameter()]
        [string] $Path = $PWD.Path,

        # When specified, the ZIP file is extracted to the same directory it was downloaded to.
        [Parameter()]
        [Alias('Extract')]
        [switch] $Expand,

        # When specified (and only meaningful if -Expand is also used), removes the ZIP file after extracting.
        [Parameter()]
        [switch] $Cleanup,

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
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/actions/artifacts/$ID/zip"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $headers = $_.Headers
            $filename = $null

            if ($headers.'Content-Disposition' -match 'filename="(?<filename>[^"]+)"') {
                $filename = $matches['filename']
            }
            if (-not $filename) {
                $filename = "artifact-$ID.zip"
            }

            # Determine if $Path is absolute, and if it has an extension
            $isAbsolute = [System.IO.Path]::IsPathFullyQualified($Path)
            $isFile = [System.IO.Path]::HasExtension($Path)

            # If $Path is not absolute, resolve it to a full path using the current location
            if (-not $isAbsolute) {
                $Path = Join-Path -Path $PWD.Path -ChildPath $Path
            }

            if ($isFile) {
                $directory = Split-Path $Path -Parent
                if (-not (Test-Path -LiteralPath $directory)) {
                    $null = New-Item -Path $directory -ItemType Directory -Force
                }
                $resolvedPath = $Path
            } else {
                if (-not (Test-Path -LiteralPath $Path)) {
                    $null = New-Item -Path $Path -ItemType Directory -Force
                }
                $resolvedPath = Join-Path -Path $Path -ChildPath $filename
            }

            Write-Debug "Resolved final download path: [$resolvedPath]"
            [System.IO.File]::WriteAllBytes($resolvedPath, $_.Response)

            if ($Expand) {
                $destPath = Split-Path $resolvedPath -Parent
                Write-Debug "Expanding artifact ZIP [$resolvedPath] to [$destPath]"
                $resolvedPath = Resolve-Path -Path $resolvedPath | Select-Object -ExpandProperty Path
                $destPath = Resolve-Path -Path $destPath | Select-Object -ExpandProperty Path
                Expand-Archive -LiteralPath $resolvedPath -DestinationPath $destPath -Force -PassThru

                if ($Cleanup) {
                    Write-Debug "Removing downloaded ZIP [$resolvedPath]"
                    Remove-Item -LiteralPath $resolvedPath -Force
                }
            } else {
                Get-Item -Path $resolvedPath
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
