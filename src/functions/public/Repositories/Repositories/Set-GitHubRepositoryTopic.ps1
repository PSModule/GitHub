filter Set-GitHubRepositoryTopic {
    <#
        .SYNOPSIS
        Replace all repository topics

        .DESCRIPTION
        Replace all repository topics

        .EXAMPLE
        Set-GitHubRepositoryTopic -Owner 'octocat' -Repo 'hello-world' -Names 'octocat', 'octo', 'octocat/hello-world'

        Replaces all topics for the repository 'octocat/hello-world' with the topics 'octocat', 'octo', 'octocat/hello-world'.

        .NOTES
        [Replace all repository topics](https://docs.github.com/rest/repos/repos#replace-all-repository-topics)
    #>
    [CmdletBinding(SupportsShouldProcess)]
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
        [Alias('Topics')]
        [string[]] $Names = @(),

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

    $body = @{
        names = $Names | ForEach-Object { $_.ToLower() }
    }

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/repos/$Owner/$Repo/topics"
        Method      = 'PUT'
        Body        = $body
    }

    if ($PSCmdlet.ShouldProcess("topics for repo [$Owner/$Repo]", 'Set')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response.names
        }
    }
}
