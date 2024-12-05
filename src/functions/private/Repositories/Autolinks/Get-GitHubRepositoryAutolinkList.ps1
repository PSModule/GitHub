filter Get-GitHubRepositoryAutolinkList {
    <#
        .SYNOPSIS
        List all autolinks of a repository

        .DESCRIPTION
        This returns a list of autolinks configured for the given repository.

        Information about autolinks are only available to repository administrators.

        .EXAMPLE
        Get-GitHubRepositoryAutolinkList -Owner 'octocat' -Repo 'Hello-World'

        Gets all autolinks for the repository 'Hello-World' owned by 'octocat'.

        .NOTES
        https://docs.github.com/rest/repos/autolinks#list-all-autolinks-of-a-repository

    #>
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('org')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repo,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    if ([string]::IsNullOrEmpty($Owner)) {
        $Owner = $Context.Owner
    }
    Write-Debug "Owner : [$($Context.Owner)]"

    if ([string]::IsNullOrEmpty($Repo)) {
        $Repo = $Context.Repo
    }
    Write-Debug "Repo : [$($Context.Repo)]"

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/repos/$Owner/$Repo/autolinks"
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
