filter Get-GitHubRepositoryTagProtection {
    <#
        .SYNOPSIS
        List tag protection states for a repository

        .DESCRIPTION
        This returns the tag protection states of a repository.

        This information is only available to repository administrators.

        .EXAMPLE
        Get-GitHubRepositoryTagProtection -Owner 'octocat' -Repo 'hello-world'

        Gets the tag protection states of the 'hello-world' repository.

        .NOTES
        [List tag protection states for a repository](https://docs.github.com/rest/repos/tags#list-tag-protection-states-for-a-repository)

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $contextObj = Get-GitHubContext -Context $Context
    if (-not $contextObj) {
        throw 'Log in using Connect-GitHub before running this command.'
    }
    Write-Debug "Context: [$Context]"

    if ([string]::IsNullOrEmpty($Owner)) {
        $Owner = $contextObj.Owner
    }
    Write-Debug "Owner : [$($contextObj.Owner)]"

    if ([string]::IsNullOrEmpty($Repo)) {
        $Repo = $contextObj.Repo
    }
    Write-Debug "Repo : [$($contextObj.Repo)]"

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/repos/$Owner/$Repo/tags/protection"
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
