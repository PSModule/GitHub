filter Get-GitHubRepositoryRule {
    <#
        .SYNOPSIS
        Get rules for a branch

        .DESCRIPTION
        Returns all active rules that apply to the specified branch. The branch does not need to exist; rules that would apply
        to a branch with that name will be returned. All active rules that apply will be returned, regardless of the level
        at which they are configured (e.g. repository or organization). Rules in rulesets with "evaluate" or "disabled"
        enforcement statuses are not returned.

        .EXAMPLE
        Get-GitHubRepositoryRule -Owner 'octocat' -Repo 'Hello-World' -Branch main

        Get rules for the main branch of the Hello-World repository owned by octocat.

        .NOTES
        https://docs.github.com/rest/repos/rules#get-rules-for-a-branch

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
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The name of the branch. Cannot contain wildcard characters. To use wildcard characters in branch names, use the GraphQL API.
        [Parameter(Mandatory)]
        [string] $Branch,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30
    )

    $body = @{
        per_page = $PerPage
    }

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/rules/branches/$Branch"
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
