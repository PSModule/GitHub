filter Set-GitHubRepositoryTopic {
    <#
        .SYNOPSIS
        Replace all repository topics

        .DESCRIPTION
        Replace all repository topics

        .EXAMPLE

        .NOTES
        https://docs.github.com/rest/repos/repos#replace-all-repository-topics

    #>
    [CmdletBinding()]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The number of results per page (max 100).
        [Parameter()]
        [Alias('names')]
        [string[]] $Topics = @()
    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case
    Remove-HashtableEntries -Hashtable $body -RemoveNames 'Owner','Repo' -RemoveTypes 'SwitchParameter'

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/topics"
        Method      = 'PUT'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
