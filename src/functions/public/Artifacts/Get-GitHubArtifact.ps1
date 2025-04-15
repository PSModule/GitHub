function Get-GitHubArtifact {
    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
        Get-GitHubArtifact -Owner 'octocat' -Repository 'Hello-World' -ArtifactID '123456'

        Output:
        ```powershell
        Name        : artifact-1
        ID          : 123456
        SizeInBytes : 2048
        CreatedAt   : 2024-12-01T10:00:00Z
        ```

        Retrieves a single GitHub Actions artifact using its unique ArtifactID.

        .EXAMPLE
        Get-GitHubArtifact -Owner 'octocat' -Repository 'Hello-World' -ID '987654321' -AllVersions

        Output:
        ```powershell
        Name        : test-results
        ID          : 456789
        SizeInBytes : 4096
        CreatedAt   : 2025-01-15T15:25:00Z
        ```

        Retrieves all versions of artifacts from the specified workflow run.

        .EXAMPLE
        Get-GitHubArtifact -Owner 'octocat' -Repository 'Hello-World'

        Output:
        ```powershell
        Name        : build-artifact
        ID          : 998877
        SizeInBytes : 8192
        CreatedAt   : 2025-02-01T09:45:00Z
        ```

        Retrieves the latest artifacts from the entire repository.

        .OUTPUTS
        GitHubArtifact[]

        .NOTES
        An array of GitHub artifact objects, each containing metadata like name, ID, and size.
        Used for inspecting, downloading, or managing GitHub Actions artifacts in workflows.

        .LINK
        https://psmodule.io/GitHub/Functions/Artifacts/Get-GitHubArtifact/
    #>
    [OutputType([GitHubArtifact[]])]
    [CmdletBinding(DefaultParameterSetName = 'FromRepository')]
    param(
        # The owner of the repository (GitHub user or org name).
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [Parameter(Mandatory, ParameterSetName = 'FromWorkflowRun', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'FromRepository')]
        [string] $Owner,

        # The name of the repository without the .git extension.
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [Parameter(Mandatory, ParameterSetName = 'FromWorkflowRun', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'FromRepository')]
        [string] $Repository,

        # Retrieves a single artifact by its unique ID.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ById',
            ValueFromPipelineByPropertyName
        )]
        [string] $ArtifactID,

        # Retrieves artifacts from a specific workflow run.
        [Parameter(
            Mandatory,
            ParameterSetName = 'FromWorkflowRun',
            ValueFromPipelineByPropertyName
        )]
        [Alias('WorkflowRunID', 'RunID', 'DatabaseID')]
        [string] $ID,

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
                Get-GitHubArtifactById @params -ID $ArtifactID
            }
            'FromWorkflowRun' {
                if ($Name.Contains('*')) {
                    Get-GitHubArtifactFromWorkflowRun @params -ID $ID -AllVersions:$AllVersions |
                        Where-Object { $_.Name -like $Name }
                } else {
                    Get-GitHubArtifactFromWorkflowRun @params -ID $ID -Name $Name -AllVersions:$AllVersions
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
