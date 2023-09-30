filter Disable-GitHubWorkflow {
    <#
        .NOTES
        https://docs.github.com/en/rest/reference/actions#disable-a-workflow
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
        APIEndpoint = "/repos/$Owner/$Repo/actions/workflows/$ID/disable"
        Method      = 'PUT'
    }

    Invoke-GitHubAPI @inputObject | Out-Null

}
