filter Enable-GitHubWorkflow {
    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE

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
        $Context = Resolve-GitHubContext -Context $Context -Anonymous $Anonymous
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'PUT'
            APIEndpoint = "/repos/$Owner/$Repository/actions/workflows/$ID/enable"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("$Owner/$Repository/$ID", 'Enable workflow')) {
            $null = Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
