filter Get-GitHubRepositoryTagProtection {
    <#
        .SYNOPSIS
        List tag protection states for a repository

        .DESCRIPTION
        This returns the tag protection states of a repository.

        This information is only available to repository administrators.

        .EXAMPLE
        Get-GitHubRepositoryTagProtection -Owner 'octocat' -Repo 'hello-world'

        Gets the tag protection states of the 'hello-world' repository.

        .NOTES
        https://docs.github.com/rest/repos/tags#list-tag-protection-states-for-a-repository

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo)
    )

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/tags/protection"
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
