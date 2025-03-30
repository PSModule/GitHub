function Export-GitHubArtifact {
    <#
        .SYNOPSIS
        Get an artifact.

        .DESCRIPTION
        Gets a specific artifact for a workflow run.
        Anyone with read access to the repository can use this endpoint.
        If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE

        .OUTPUTS
        System.IO.FileSystemInfo[]

        .NOTES

        .LINK
        [Get an artifact](https://docs.github.com/rest/actions/artifacts#get-an-artifact)
    #>
    [OutputType([System.IO.FileSystemInfo[]])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The unique identifier of the artifact.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('ID', 'DatabaseID')]
        [string] $ArtifactID,

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
            APIEndpoint = "/repos/$Owner/$Repository/actions/artifacts/$ArtifactID/zip"
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
