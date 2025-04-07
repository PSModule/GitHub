function Remove-GitHubArtifact {
    <#
        .SYNOPSIS
        Deletes an artifact from a GitHub repository by its unique ID.

        .DESCRIPTION
        Deletes an artifact associated with a workflow run in a GitHub repository.
        The user must provide the repository owner, repository name, and the artifact ID.
        OAuth tokens and personal access tokens (classic) must have the `repo` scope to use this endpoint.
        The function uses the GitHub REST API to perform the deletion and supports `ShouldProcess` for safe execution.

        .EXAMPLE
        Remove-GitHubArtifact -Owner 'octocat' -Repository 'demo-repo' -ID '123456'

        Deletes the artifact with ID 123456 from the repository 'demo-repo' owned by 'octocat'.

        .INPUTS
        GitHubArtifact

        .OUTPUTS
        void

        .NOTES
        This function does not return any output.
        It performs a delete operation against the GitHub REST API and is silent on success.

        .LINK
        https://psmodule.io/GitHub/Functions/Actions/Remove-GitHubArtifact/

        .LINK
        [Delete an artifact](https://docs.github.com/rest/actions/artifacts#delete-an-artifact)
    #>
    [OutputType([GitHubArtifact])]
    [CmdletBinding(SupportsShouldProcess)]
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
            Method      = 'DELETE'
            APIEndpoint = "/repos/$Owner/$Repository/actions/artifacts/$ID"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("artifact [$Owner/$Repository/$ID]", 'Remove')) {
            $null = Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
