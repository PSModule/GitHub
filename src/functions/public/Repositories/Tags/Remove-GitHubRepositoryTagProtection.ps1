filter Remove-GitHubRepositoryTagProtection {
    <#
        .SYNOPSIS
        Delete a tag protection state for a repository

        .DESCRIPTION
        This deletes a tag protection state for a repository.
        This endpoint is only available to repository administrators.

        .EXAMPLE
        Remove-GitHubRepositoryTagProtection -Owner 'octocat' -Repo 'hello-world' -TagProtectionId 1

        Deletes the tag protection state with the ID 1 for the 'hello-world' repository.

        .NOTES
        [Delete a tag protection state for a repository](https://docs.github.com/rest/repos/tags#delete-a-tag-protection-state-for-a-repository)

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # The unique identifier of the tag protection.
        [Parameter(Mandatory)]
        [int] $TagProtectionId,

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
        APIEndpoint = "/repos/$Owner/$Repo/tags/protection/$TagProtectionId"
        Method      = 'DELETE'
    }

    if ($PSCmdlet.ShouldProcess("tag protection state with ID [$TagProtectionId] for repository [$Owner/$Repo]", 'Delete')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
