function Get-GitHubArtifactById {
    <#
        .SYNOPSIS
        Retrieves a specific artifact from a GitHub Actions workflow run.

        .DESCRIPTION
        Gets a single artifact from a workflow run in the specified repository by its unique identifier.
        Requires authentication via OAuth or personal access token with `repo` scope for private repositories.
        The function returns a custom GitHubArtifact object containing metadata and download information for the artifact.

        .EXAMPLE
        Get-GitHubArtifactById -Owner 'octocat' -Repository 'hello-world' -ID '123456'

        Output:
        ```powershell
        Name               : build-artifact
        ID                 : 123456
        Url                : https://api.github.com/repos/octocat/hello-world/actions/artifacts/123456
        Size               : 102400
        ArchiveDownloadUrl : https://github.com/download/artifact.zip
        Expired            : False
        ```

        Retrieves the artifact with ID 123456 from the 'hello-world' repository owned by 'octocat'.

        .OUTPUTS
        GitHubArtifact

        .NOTES
        A GitHubArtifact object representing a workflow artifact from the run.
        When -AllVersions is used, all versions of each artifact name are returned instead of the latest only.

        .NOTES
        [Get an artifact](https://docs.github.com/rest/actions/artifacts#get-an-artifact)
    #>
    [OutputType([GitHubArtifact])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The unique identifier of the artifact.
        [Parameter(Mandatory)]
        [string] $ID,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/actions/artifacts/$ID"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            [GitHubArtifact]::new($_.Response, $Owner, $Repository)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
