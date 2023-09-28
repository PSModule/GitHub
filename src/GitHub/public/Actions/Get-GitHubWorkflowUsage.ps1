Function Get-GitHubWorkflowUsage {
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
        https://docs.github.com/en/rest/reference/actions#get-workflow-usage
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'ByName'
    )]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string[]] $ID
    )

    begin {}

    process {

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repo/actions/workflows/$ID/timing"
        }

        Invoke-GitHubAPI @inputObject

    }

    end {}
}
