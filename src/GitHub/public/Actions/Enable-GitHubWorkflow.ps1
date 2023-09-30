filter Enable-GitHubWorkflow {
    <#
        .NOTES
        https://docs.github.com/en/rest/reference/actions#enable-a-workflow
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

    Invoke-GitHubAPI @inputObject | Out-Null

}
