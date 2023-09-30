function Stop-GitHubWorkflowRun {
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
        https://docs.github.com/en/rest/reference/actions#cancel-a-workflow-run
    #>
    [CmdletBinding()]
    [alias('Cancel-GitHubWorkflowRun')]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        [Alias('workflow_id')]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $ID
    )

    begin {}

    process {

        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = "/repos/$Owner/$Repo/actions/runs/$ID/cancel"
        }

        (Invoke-GitHubAPI @inputObject).Response

    }

    end {}
}
