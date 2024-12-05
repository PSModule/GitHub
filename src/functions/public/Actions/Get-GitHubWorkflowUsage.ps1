filter Get-GitHubWorkflowUsage {
    <#
        .SYNOPSIS
        Short description

        .DESCRIPTION
        Long description

        .EXAMPLE
        An example

        .NOTES
        [Get workflow usage](https://docs.github.com/en/rest/actions/workflows#get-workflow-usage)
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'ByName'
    )]
    param(
        [Parameter()]
        [string] $Owner,

        [Parameter()]
        [string] $Repo,

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

    $Context = Resolve-GitHubContext -Context $Context

    if ([string]::IsNullOrEmpty($Owner)) {
        $Owner = $Context.Owner
    }
    Write-Debug "Owner : [$($Context.Owner)]"

    if ([string]::IsNullOrEmpty($Repo)) {
        $Repo = $Context.Repo
    }
    Write-Debug "Repo : [$($Context.Repo)]"

    $inputObject = @{
        Context     = $Context
        Method      = 'GET'
        APIEndpoint = "/repos/$Owner/$Repo/actions/workflows/$ID/timing"
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response.billable
    }

}
