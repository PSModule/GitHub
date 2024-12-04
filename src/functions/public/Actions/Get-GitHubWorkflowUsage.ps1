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

        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $contextObj = Get-GitHubContext -Context $Context
    if (-not $contextObj) {
        throw 'Log in using Connect-GitHub before running this command.'
    }
    Write-Debug "Context: [$Context]"

    if ([string]::IsNullOrEmpty($Owner)) {
        $Owner = $contextObj.Owner
    }
    Write-Debug "Owner : [$($contextObj.Owner)]"

    if ([string]::IsNullOrEmpty($Repo)) {
        $Repo = $contextObj.Repo
    }
    Write-Debug "Repo : [$($contextObj.Repo)]"

    $inputObject = @{
        Context     = $Context
        Method      = 'GET'
        APIEndpoint = "/repos/$Owner/$Repo/actions/workflows/$ID/timing"
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response.billable
    }

}
