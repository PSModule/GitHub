filter Enable-GitHubWorkflow {
    <#
        .SYNOPSIS
        Enable a workflow

        .DESCRIPTION
        Enables a workflow and sets the `state` of the workflow to `active`. You can use workflow
        filename and ID in the `ID` parameter. For example, you could use `main.yaml`.

        OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        ```powershell
        Enable-GitHubWorkflow -Owner 'PSModule' -Repository 'GitHub' -ID 'main.yaml'
        ```

        Enables the workflow with the filename 'main.yaml' in the PSModule/GitHub repository.

        .EXAMPLE
        ```powershell
        Enable-GitHubWorkflow -Owner 'PSModule' -Repository 'GitHub' -ID 161335
        ```

        Enables the workflow with the ID 161335 in the PSModule/GitHub repository.

        .INPUTS
        GitHubWorkflow

        .LINK
        https://psmodule.io/GitHub/Functions/Workflows/Enable-GitHubWorkflow/

        .NOTES
        [Enable a workflow](https://docs.github.com/rest/actions/workflows#enable-a-workflow)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The ID of the workflow. You can also pass the workflow filename as a string.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $ID,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $apiParams = @{
            Method      = 'PUT'
            APIEndpoint = "/repos/$Owner/$Repository/actions/workflows/$ID/enable"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("$Owner/$Repository/$ID", 'Enable workflow')) {
            $null = Invoke-GitHubAPI @apiParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
