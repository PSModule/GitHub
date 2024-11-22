filter Get-GitHubWorkflowUsage {
    <#
        .SYNOPSIS
        Short description

        .DESCRIPTION
        Long description

        .PARAMETER Owner
        Parameter description

        .PARAMETER Repo
        Parameter description

        .PARAMETER ID
        Parameter description

        .EXAMPLE
        An example

        .NOTES
        [Get workflow usage](https://docs.github.com/en/rest/actions/workflows#get-workflow-usage)
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'ByName'
    )]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubContextSetting -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubContextSetting -Name Repo),

        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string[]] $ID
    )

    $inputObject = @{
        Method      = 'GET'
        APIEndpoint = "/repos/$Owner/$Repo/actions/workflows/$ID/timing"
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response.billable
    }

}
