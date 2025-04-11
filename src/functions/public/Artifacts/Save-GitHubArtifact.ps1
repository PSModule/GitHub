function Save-GitHubArtifact {
    <#
        .SYNOPSIS
        Downloads a GitHub Actions artifact.

        .DESCRIPTION
        Downloads an artifact from a repository. The artifact is downloaded as a ZIP file to the specified path
        or the current directory by default. Users must have read access to the repository. For private repositories,
        personal access tokens (classic) or OAuth tokens with the `repo` scope are required.

        .EXAMPLE
        Save-GitHubArtifact -Owner 'octocat' -Repository 'Hello-World' -ID '123456' -Path 'C:\Artifacts'

        Output:
        ```powershell
        Directory: C:\Artifacts

        Mode                 LastWriteTime         Length Name
        ----                 -------------         ------ ----
        d-----        03/31/2025     12:00                artifact-123456.zip
        ```

        Downloads artifact ID '123456' from the 'Hello-World' repository owned by 'octocat' to the specified path.

        .EXAMPLE
        Save-GitHubArtifact -Owner 'octocat' -Repository 'Hello-World' -Name 'module' -Path 'C:\Artifacts\module' -Expand -Cleanup

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
        https://psmodule.io/GitHub/Functions/Artifacts/Save-GitHubArtifact/

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
        [string] $ID,

        # Path to the file or folder for the download. Accepts relative or absolute paths.
        [Parameter()]
        [string] $Path = $PWD.Path,

        # When specified, the ZIP file is extracted to the same directory it was downloaded to.
        [Parameter()]
        [Alias('Extract')]
        [switch] $Expand,

        # When specified, the zip file or the folder where the zip file was extracted to is returned.
        [Parameter()]
        [switch] $PassThru,

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
            $itemType = $Path.EndsWith('.zip') ? 'File' : 'Directory'
            $isAbsolute = [System.IO.Path]::IsPathRooted($Path)
            Write-Debug "Path:        [$Path]"
            Write-Debug "Type:        [$itemType]"
            Write-Debug "Is absolute: [$isAbsolute]"

            if ($itemType -eq 'Directory') {
                if ($headers.'Content-Disposition' -match 'filename="(?<filename>[^"]+)"') {
                    $filename = $matches['filename']
                } else {
                    Write-Debug 'No filename found in Content-Disposition header. Getting artifact name.'
                    $artifactName = (Get-GitHubArtifact -Owner $Owner -Repository $Repository -ID $ID -Context $Context).Name
                    $filename = "$artifactName.zip"
                }
                $Path = Join-Path -Path $Path -ChildPath $filename
            }

            $folderPath = [System.IO.Path]::GetDirectoryName($Path)
            $folder = New-Item -Path $folderPath -ItemType Directory -Force
            Write-Debug "Resolved final download path: [$Path]"
            [System.IO.File]::WriteAllBytes($Path, $_.Response)

            if ($Expand) {
                Write-Debug "Expanding artifact to [$folder]"
                Expand-Archive -LiteralPath $Path -DestinationPath $folder -Force
                Write-Debug "Removing downloaded ZIP [$Path]"
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
