filter Get-GitHubRepoBranch {
    <#
        .SYNOPSIS
        List branches

        .DESCRIPTION
        Lists all branches from a repository

        .EXAMPLE
        Get-GitHubRepoBranch -Owner 'octocat' -Repo 'Hello-World'

        Gets all the branches from the 'Hello-World' repository owned by 'octocat'

        .NOTES
        https://docs.github.com/rest/branches/branches#list-branches
    #>
    [CmdletBinding()]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo)
    )

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/branches"
        Method      = 'GET'
    }

    (Invoke-GitHubAPI @inputObject).Response

}
