filter Get-GitHubRepositoryTag {
    <#
        .SYNOPSIS
        List repository tags

        .DESCRIPTION
        List repository tags

        .EXAMPLE
        Get-GitHubRepositoryTag -Owner 'PSModule' -Repo 'GitHub'

        Gets all tags of the GitHub repository.

        .NOTES
        [List repository tags](https://docs.github.com/rest/repos/repos#list-repository-tags)

    #>
    [CmdletBinding()]
    [Alias('Get-GitHubRepositoryTags')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage,

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

    $body = @{
        per_page = $PerPage
    }

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/repos/$Owner/$Repo/tags"
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
