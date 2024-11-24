filter Disable-GitHubWorkflow {
    <#
        .NOTES
        [Disable a workflow](https://docs.github.com/en/rest/actions/workflows#disable-a-workflow)
    #>
    [CmdletBinding()]
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
        APIEndpoint = "/repos/$Owner/$Repo/actions/workflows/$ID/disable"
        Method      = 'PUT'
    }

    $null = Invoke-GitHubAPI @inputObject

}
