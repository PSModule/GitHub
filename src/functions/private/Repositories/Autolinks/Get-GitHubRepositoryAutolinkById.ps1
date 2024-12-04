filter Get-GitHubRepositoryAutolinkById {
    <#
        .SYNOPSIS
        Get an autolink reference of a repository

        .DESCRIPTION
        This returns a single autolink reference by ID that was configured for the given repository.

        Information about autolinks are only available to repository administrators.

        .EXAMPLE
        Get-GitHubRepositoryAutolinkById -Owner 'octocat' -Repo 'Hello-World' -ID 1

        Gets the autolink with the ID 1 for the repository 'Hello-World' owned by 'octocat'.

        .NOTES
        https://docs.github.com/rest/repos/autolinks#get-an-autolink-reference-of-a-repository

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

        # The unique identifier of the autolink.
        [Parameter(Mandatory)]
        [Alias('autolink_id')]
        [Alias('ID')]
        [int] $AutolinkId,

        # The context to run the command in.
        [Parameter()]
        [string] $Context
    )

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/repos/$Owner/$Repo/autolinks/$AutolinkId"
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
