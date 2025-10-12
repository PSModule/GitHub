filter Get-GitHubRepositoryAutolink {
    <#
        .SYNOPSIS
        List all autolinks of a repository

        .DESCRIPTION
        This returns a list of autolinks configured for the given repository.

        Information about autolinks are only available to repository administrators.

        .EXAMPLE
        ```powershell
        Get-GitHubRepositoryAutolink -Owner 'octocat' -Repository 'Hello-World'
        ```

        Gets all autolinks for the repository 'Hello-World' owned by 'octocat'.

        .EXAMPLE
        ```powershell
        Get-GitHubRepositoryAutolink -Owner 'octocat' -Repository 'Hello-World' -ID 1
        ```

        Gets the autolink with the ID 1 for the repository 'Hello-World' owned by 'octocat'.

        .NOTES
        [Get all autolinks of a repository](https://docs.github.com/rest/repos/autolinks#list-all-autolinks-of-a-repository)

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Autolinks/Get-GitHubRepositoryAutolink
    #>
    [Alias('Get-GitHubRepositoryAutolinks')]
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The unique identifier of the autolink.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ById'
        )]
        [Alias('autolink_id', 'AutolinkID')]
        [int] $ID,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                Get-GitHubRepositoryAutolinkById -Owner $Owner -Repository $Repository -ID $ID -Context $Context
            }
            default {
                Get-GitHubRepositoryAutolinkList -Owner $Owner -Repository $Repository -Context $Context
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
