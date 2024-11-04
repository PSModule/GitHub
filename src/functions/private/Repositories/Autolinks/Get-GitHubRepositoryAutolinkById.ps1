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
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The unique identifier of the autolink.
        [Parameter(Mandatory)]
        [Alias('autolink_id')]
        [Alias('ID')]
        [int] $AutolinkId
    )

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/autolinks/$AutolinkId"
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
