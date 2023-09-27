function Get-GitHubWorkflow {
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
    https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#list-repository-workflows
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        [Parameter(ParameterSetName = 'ByName')]
        [string] $Name,

        [Parameter(ParameterSetName = 'ByID')]
        [string] $ID,

        [Parameter()]
        [int] $PageSize = 100
    )

    $processedPages = 0
    $workflows = @()
    do {
        $processedPages++
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repo/actions/workflows?per_page=$PageSize&page=$processedPages"
        }
        $response = Invoke-GitHubAPI @inputObject
        $workflows += $response.workflows | Where-Object name -Match $name | Where-Object id -Match $id
    } while ($workflows.count -ne $response.total_count)
    $workflows
}
