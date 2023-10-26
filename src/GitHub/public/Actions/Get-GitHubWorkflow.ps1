filter Get-GitHubWorkflow {
    <#
        .SYNOPSIS
        Lists the workflows in a repository.

        .DESCRIPTION
        Anyone with read access to the repository can use this endpoint.
        If the repository is private you must use an access token with the repo scope.
        GitHub Apps must have the actions:read permission to use this endpoint.

        .EXAMPLE
        Get-GitHubWorkflow -Owner 'octocat' -Repo 'hello-world'

        Gets all workflows in the 'octocat/hello-world' repository.

        .EXAMPLE
        Get-GitHubWorkflow -Owner 'octocat' -Repo 'hello-world' -Name 'hello-world.yml'

        Gets the 'hello-world.yml' workflow in the 'octocat/hello-world' repository.

        .NOTES
        https://docs.github.com/rest/actions/workflows?apiVersion=2022-11-28#list-repository-workflows
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30
    )


    $body = @{
        per_page = $PerPage
    }

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/actions/workflows"
        Method      = 'GET'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response.workflows

}
