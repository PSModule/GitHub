filter Get-GitHubRepositoryLanguage {
    <#
        .SYNOPSIS
        List repository languages

        .DESCRIPTION
        Lists languages for the specified repository. The value shown for each language is the number of
        bytes of code written in that language.

        .EXAMPLE
        Get-GitHubRepositoryLanguage -Owner 'octocat' -Repo 'hello-world'

        Gets the languages for the 'hello-world' repository owned by 'octocat'.

        .NOTES
        [List repository languages](https://docs.github.com/rest/repos/repos#list-repository-languages)

    #>
    [CmdletBinding()]
    [Alias('Get-GitHubRepositoryLanguages')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
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
        APIEndpoint = "/repos/$Owner/$Repo/languages"
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
