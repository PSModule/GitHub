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

        # Path to the file to download. If not specified, the artifact will be downloaded to the current directory.
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

        # Call the GitHub API (this returns a stream response)
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $headers = $_.Headers
            $filename = $null

            if ($headers.'Content-Disposition' -match 'filename="(?<filename>[^"]+)"') {
                $filename = $matches['filename']
            }

            # If the path is an existing directory, or a non-existent path with no extension, treat it as a folder
            if (Test-Path -LiteralPath $Path -PathType Container) {
                # $Path is an existing directory
                if (-not $filename) {
                    $filename = "artifact-$ID.zip"
                }
                $resolvedPath = Join-Path -Path $Path -ChildPath $filename
            } elseif (-not (Test-Path -LiteralPath $Path) -and [string]::IsNullOrEmpty([IO.Path]::GetExtension($Path))) {
                # $Path doesn't exist but has no extension -> treat as a folder
                if (-not $filename) {
                    $filename = "artifact-$ID.zip"
                }
                $resolvedPath = Join-Path -Path $Path -ChildPath $filename
            } else {
                # $Path is a file path (existing or not) or has an extension; use it directly
                $resolvedPath = $Path
            }

            # Ensure the directory portion of $resolvedPath exists
            $directory = Split-Path -Path $resolvedPath -Parent
            if ([string]::IsNullOrEmpty($directory)) {
                $directory = $PWD.Path
            }
            if (-not (Test-Path -LiteralPath $directory -PathType Container)) {
                New-Item -ItemType Directory -Path $directory -Force | Out-Null
            }

            Write-Debug "Downloading artifact ZIP to [$resolvedPath]"
            [System.IO.File]::WriteAllBytes($resolvedPath, $_.Response)

            if ($Expand) {
                Write-Debug "Expanding artifact ZIP [$resolvedPath] to [$directory]"
                Expand-Archive -LiteralPath $resolvedPath -DestinationPath $directory -Force -PassThru

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
