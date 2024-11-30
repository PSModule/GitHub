filter Get-GitHubRepositoryAutolink {
    <#
        .SYNOPSIS
        List all autolinks of a repository

        .DESCRIPTION
        This returns a list of autolinks configured for the given repository.

        Information about autolinks are only available to repository administrators.

        .EXAMPLE
        Get-GitHubRepositoryAutolink -Owner 'octocat' -Repo 'Hello-World'

        Gets all autolinks for the repository 'Hello-World' owned by 'octocat'.

        .EXAMPLE
        Get-GitHubRepositoryAutolink -Owner 'octocat' -Repo 'Hello-World' -ID 1

        Gets the autolink with the ID 1 for the repository 'Hello-World' owned by 'octocat'.

        .NOTES
        [Get all autolinks of a repository](https://docs.github.com/rest/repos/autolinks#list-all-autolinks-of-a-repository)

    #>
    [Alias('Get-GitHubRepositoryAutolinks')]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubContextSetting -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubContextSetting -Name Repo),

        # The unique identifier of the autolink.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ById'
        )]
        [Alias('autolink_id')]
        [Alias('ID')]
        [int] $AutolinkId
    )

    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            Get-GitHubRepositoryAutolinkById -Owner $Owner -Repo $Repo -ID $AutolinkId
        }
        default {
            Get-GitHubRepositoryAutolinkList -Owner $Owner -Repo $Repo
        }
    }
}
