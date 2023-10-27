filter Set-GitHubRepositoryTopic {
    <#
        .SYNOPSIS
        Replace all repository topics

        .DESCRIPTION
        Replace all repository topics

        .EXAMPLE
        Set-GitHubRepositoryTopic -Owner 'octocat' -Repo 'hello-world' -Names 'octocat', 'octo', 'octocat/hello-world'

        Replaces all topics for the repository 'octocat/hello-world' with the topics 'octocat', 'octo', 'octocat/hello-world'.

        .NOTES
        https://docs.github.com/rest/repos/repos#replace-all-repository-topics
    #>
    [CmdletBinding(SupportsShouldProcess)]
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
        [Alias('Topics')]
        [string[]] $Names = @()
    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case
    Remove-HashtableEntries -Hashtable $body -RemoveNames 'Owner', 'Repo' -RemoveTypes 'SwitchParameter'

    $body.names = $body.names | ForEach-Object { $_.ToLower() }

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/topics"
        Method      = 'PUT'
        Body        = $body
    }

    if ($PSCmdlet.ShouldProcess("topics for repo [$Owner/$Repo]", "Set")) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response.names
        }
    }
}
