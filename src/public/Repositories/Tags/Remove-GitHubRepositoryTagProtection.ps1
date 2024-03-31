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
        https://docs.github.com/rest/repos/tags#delete-a-tag-protection-state-for-a-repository

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The unique identifier of the tag protection.
        [Parameter(Mandatory)]
        [int] $TagProtectionId
    )

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/tags/protection/$TagProtectionId"
        Method      = 'DELETE'
    }

    if ($PSCmdlet.ShouldProcess("tag protection state with ID [$TagProtectionId] for repository [$Owner/$Repo]", 'Delete')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
