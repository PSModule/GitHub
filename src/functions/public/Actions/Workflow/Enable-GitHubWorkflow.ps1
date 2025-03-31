filter Enable-GitHubWorkflow {
    <#
        .NOTES
        [Enable a workflow](https://docs.github.com/rest/actions/workflows#enable-a-workflow)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Repository,

        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string[]] $ID,

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
        $inputObject = @{
            Method      = 'PUT'
            APIEndpoint = "/repos/$Owner/$Repository/actions/workflows/$ID/enable"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("$Owner/$Repository/$ID", 'Enable workflow')) {
            Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
