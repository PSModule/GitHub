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
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # The unique identifier of the autolink.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ById'
        )]
        [Alias('autolink_id')]
        [Alias('ID')]
        [int] $AutolinkId,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner : [$($Context.Owner)]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo : [$($Context.Repo)]"
    }

    process {
        try {
            switch ($PSCmdlet.ParameterSetName) {
                'ById' {
                    Get-GitHubRepositoryAutolinkById -Owner $Owner -Repo $Repo -ID $AutolinkId -Context $Context
                }
                default {
                    Get-GitHubRepositoryAutolinkList -Owner $Owner -Repo $Repo -Context $Context
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
