function Get-GitHubArtifact {
    <#
        .SYNOPSIS
        Retrieves GitHub Actions artifacts from a repository or workflow run.

        .DESCRIPTION
        This function fetches GitHub Actions artifacts by artifact ID, workflow run ID, or directly from a repository.
        It supports filtering by artifact name (with wildcards) and can optionally retrieve all versions of the artifacts.
        Artifacts contain metadata such as name, size, ID, and creation date. The function supports multiple parameter sets:
        - ById: Retrieve a specific artifact by its ID.
        - FromWorkflowRun: Retrieve artifacts from a specific workflow run.
        - FromRepository: Retrieve artifacts from a repository, optionally by name or with all versions.

        .EXAMPLE
        Get-GitHubArtifact -Owner 'octocat' -Repository 'Hello-World' -ID '123456'

        Output:
        ```powershell
        Name        : artifact-1
        ID          : 123456
        SizeInBytes : 2048
        CreatedAt   : 2024-12-01T10:00:00Z
        ```

        Retrieves a single GitHub Actions artifact using its unique artifact ID.

        .EXAMPLE
        Get-GitHubArtifact -Owner 'octocat' -Repository 'Hello-World' -WorkflowRunID '987654321'

        Output:
        ```powershell
        Name        : test-results
        ID          : 456789
        SizeInBytes : 4096
        CreatedAt   : 2025-01-15T15:25:00Z
        ```

        Retrieves the latest version of all artifacts from the specified workflow run.

        .EXAMPLE
        Get-GitHubArtifact -Owner 'octocat' -Repository 'Hello-World' -WorkflowRunID '987654321' -AllVersions

        Output:
        ```powershell
        Name        : test-results
        ID          : 4564584673
        SizeInBytes : 4096
        CreatedAt   : 2025-01-15T14:25:00Z

        Name        : test-results
        ID          : 4564584674
        SizeInBytes : 4096
        CreatedAt   : 2025-01-15T15:25:00Z
        ```

        Retrieves all versions of all artifacts from the specified workflow run.

        .EXAMPLE
        Get-GitHubArtifact -Owner 'octocat' -Repository 'Hello-World'

        Output:
        ```powershell
        Name        : build-artifact
        ID          : 998877
        SizeInBytes : 8192
        CreatedAt   : 2025-02-01T09:45:00Z
        ```

        Retrieves the latest version of all artifacts from the specified repository.

        .OUTPUTS
        GitHubArtifact[]        .LINK
        https://psmodule.io/GitHub/Functions/Artifacts/Get-GitHubArtifact/
    #>

    [OutputType([GitHubArtifact[]])]
    [CmdletBinding(DefaultParameterSetName = 'FromRepository')]
    param(
        # The owner of the repository (GitHub user or org name).
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'FromWorkflowRun', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'FromRepository', ValueFromPipelineByPropertyName)]
        [string] $Owner,

        # The name of the repository without the .git extension.
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'FromWorkflowRun', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'FromRepository', ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # Retrieves a single artifact by its unique ID.
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string] $ID,

        # Retrieves artifacts from a specific workflow run.
        [Parameter(Mandatory, ParameterSetName = 'FromWorkflowRun', ValueFromPipelineByPropertyName)]
        [Alias('WorkflowRun')]
        [string] $WorkflowRunID,

        # Retrieves artifacts by name or all artifacts across a repo.
        [Parameter(ParameterSetName = 'FromRepository')]
        [Parameter(ParameterSetName = 'FromWorkflowRun')]
        [SupportsWildcards()]
        [string] $Name,

        # Return all versions of artifacts.
        [Parameter(ParameterSetName = 'FromRepository')]
        [Parameter(ParameterSetName = 'FromWorkflowRun')]
        [switch] $AllVersions,

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
        $params = @{
            Owner      = $Owner
            Repository = $Repository
            Context    = $Context
        }
        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                Get-GitHubArtifactById @params -ID $ID
            }
            'FromWorkflowRun' {
                if ($Name.Contains('*')) {
                    Get-GitHubArtifactFromWorkflowRun @params -ID $WorkflowRunID -AllVersions:$AllVersions |
                        Where-Object { $_.Name -like $Name }
                } else {
                    Get-GitHubArtifactFromWorkflowRun @params -ID $WorkflowRunID -Name $Name -AllVersions:$AllVersions
                }
            }
            'FromRepository' {
                if ($Name.Contains('*')) {
                    Get-GitHubArtifactFromRepository @params -AllVersions:$AllVersions |
                        Where-Object { $_.Name -like $Name }
                } else {
                    Get-GitHubArtifactFromRepository @params -Name $Name -AllVersions:$AllVersions
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
