﻿function Get-GitHubArtifactFromRepository {
    <#
        .SYNOPSIS
        Lists artifacts for a GitHub repository.

        .DESCRIPTION
        Retrieves all workflow artifacts associated with a specified GitHub repository.
        Anyone with read access to the repository can invoke this function.
        For private repositories, personal access tokens or OAuth tokens must include the `repo` scope.
        By default, only the latest version of each artifact is returned unless -AllVersions is specified.

        .EXAMPLE
        Get-GitHubArtifactFromRepository -Owner 'octocat' -Repository 'demo-repo' -AllVersions

        Output:
        ```powershell
        Name        : build-output
        ID          : 4567890
        Expired     : False
        CreatedAt   : 3/31/2025 2:43:12 PM
        ```

        Retrieves all versions of the 'build-output' artifact from the 'demo-repo' repository owned by 'octocat'.

        .OUTPUTS
        GitHubArtifact[]

        .NOTES
        A list of GitHubArtifact objects representing workflow artifacts from the run.
        When -AllVersions is used, all versions of each artifact name are returned instead of the latest only.

        .NOTES
        [List artifacts for a repository](https://docs.github.com/rest/actions/artifacts#list-artifacts-for-a-repository)
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

        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/actions/artifacts"
            Body        = $body
            Context     = $Context
        }

        $response = Invoke-GitHubAPI @apiParams

        $artifacts = $response.Response.artifacts |
            Sort-Object -Property created_at -Descending

        if (-not $AllVersions) {
            $artifacts = $artifacts | Group-Object -Property name | ForEach-Object {
                $_.Group | Select-Object -First 1
            }
        }

        $artifacts | ForEach-Object {
            [GitHubArtifact]::new($_, $Owner, $Repository, $Context)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
