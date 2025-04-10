function Get-GitHubArtifactFromWorkflowRun {
    <#
        .SYNOPSIS
        Retrieves artifacts from a specific GitHub Actions workflow run.

        .DESCRIPTION
        Lists all artifacts generated by a given GitHub Actions workflow run. Users must have read access to the
        repository. For private repositories, OAuth and personal access tokens must have the `repo` scope.
        The function can optionally filter artifacts by name or return only the latest version per artifact name.

        .EXAMPLE
        Get-GitHubArtifactFromWorkflowRun -Owner 'octocat' -Repository 'demo' -ID '123456789'

        Output:
        ```powershell
        ID                 : 10
        NodeID             : MDEwOkFydGlmYWN0MQ==
        Name               : build-logs
        Size               : 24576
        Url                : https://api.github.com/repos/octocat/demo/actions/artifacts/10
        ArchiveDownloadUrl : https://api.github.com/repos/octocat/demo/actions/artifacts/10/zip
        Expired            : False
        Digest             : abc123def456
        CreatedAt          : 2024-01-01T12:00:00Z
        UpdatedAt          : 2024-01-01T12:10:00Z
        ExpiresAt          : 2024-02-01T12:00:00Z
        WorkflowRun        : @{id=123456789; name=CI}
        ```

        Retrieves all artifacts for the given workflow run, returning only the latest version of each artifact.

        .OUTPUTS
        GitHubArtifact[]

        .NOTES
        A list of GitHubArtifact objects representing workflow artifacts from the run.
        When -AllVersions is used, all versions of each artifact name are returned instead of the latest only.

        .LINK
        [List workflow run artifacts](https://docs.github.com/rest/actions/artifacts#list-workflow-run-artifacts)
    #>
    [OutputType([GitHubArtifact[]])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The unique identifier of the workflow run.
        [Parameter(Mandatory)]
        [Alias('WorkflowRunID', 'RunID', 'DatabaseID')]
        [string] $ID,

        # The name field of an artifact. When specified, only artifacts with this name will be returned.
        [Parameter()]
        [string] $Name,

        # Return all versions of artifacts. This will include artifacts from all runs from the workflow.
        [Parameter()]
        [switch] $AllVersions,

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
        $body = @{
            name = $Name
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/actions/runs/$ID/artifacts"
            Body        = $body
            Context     = $Context
        }

        $response = Invoke-GitHubAPI @inputObject

        $artifacts = $response.Response.artifacts |
            Sort-Object -Property created_at -Descending

        if (-not $AllVersions) {
            $artifacts = $artifacts | Group-Object -Property name | ForEach-Object {
                $_.Group | Select-Object -First 1
            }
        }

        $artifacts | ForEach-Object {
            [GitHubArtifact]::new($_, $Owner, $Repository)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
