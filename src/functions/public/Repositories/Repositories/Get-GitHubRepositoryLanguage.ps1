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
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubContextSetting -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubContextSetting -Name Repo)
    )

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/languages"
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
