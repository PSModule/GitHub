filter New-GitHubRepositoryTagProtection {
    <#
        .SYNOPSIS
        Create a tag protection state for a repository

        .DESCRIPTION
        This creates a tag protection state for a repository.
        This endpoint is only available to repository administrators.

        .EXAMPLE
        New-GitHubRepositoryTagProtection -Owner 'octocat' -Repo 'hello-world' -Pattern 'v1.*'

        Creates a tag protection state for the 'hello-world' repository with the pattern 'v1.*'.

        .NOTES
        [Create a tag protection state for a repository](https://docs.github.com/rest/repos/tags#create-a-tag-protection-state-for-a-repository)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubContextSetting -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubContextSetting -Name Repo),

        # An optional glob pattern to match against when enforcing tag protection.
        [Parameter(Mandatory)]
        [string] $Pattern
    )

    $body['pattern'] = $Pattern

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/tags/protection"
        Method      = 'POST'
        Body        = $body
    }

    if ($PSCmdlet.ShouldProcess("tag protection state on pattern [$Pattern] for repository [$Owner/$Repo]", 'Create')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
