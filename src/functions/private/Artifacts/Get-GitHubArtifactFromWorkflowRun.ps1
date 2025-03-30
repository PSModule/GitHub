function Get-GitHubArtifactFromWorkflowRun {
    <#

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
        [string] $RunID,

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
            APIEndpoint = "/repos/$Owner/$Repository/actions/runs/$RunID/artifacts"
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
            [GitHubArtifact]@{
                DatabaseID         = $_.id
                NodeID             = $_.node_id
                Name               = $_.name
                Size               = $_.size_in_bytes
                Url                = $_.url
                ArchiveDownloadUrl = $_.archive_download_url
                Expired            = $_.expired
                Digest             = $_.digest
                CreatedAt          = $_.created_at
                UpdatedAt          = $_.updated_at
                ExpiresAt          = $_.expires_at
                WorkflowRun        = $_.workflow_run
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
