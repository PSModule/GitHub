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
        d-----        03/31/2025     12:00                artifact-123456
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
        [string] $Path = (Get-Location).Path,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)

        # [Parameter(Mandatory)]
        # [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/actions/artifacts/$ID/zip"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject -DownloadFilePath $Path | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
