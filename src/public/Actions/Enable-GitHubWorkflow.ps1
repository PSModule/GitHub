﻿filter Enable-GitHubWorkflow {
    <#
        .NOTES
        [Enable a workflow](https://docs.github.com/en/rest/actions/workflows#enable-a-workflow)
    #>
    [CmdletBinding()]
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

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/actions/workflows/$ID/enable"
        Method      = 'PUT'
    }

    $null = Invoke-GitHubAPI @inputObject
}
