filter Remove-GitHubRepository {
    <#
        .SYNOPSIS
        Delete a repository

        .DESCRIPTION
        Deleting a repository requires admin access. If OAuth is used, the `delete_repo` scope is required.

        If an organization owner has configured the organization to prevent members from deleting organization-owned
        repositories, you will get a `403 Forbidden` response.

        .EXAMPLE
        Remove-GitHubRepository -Owner 'PSModule' -Repo 'Hello-World'

        Deletes the repository `Hello-World` in the `PSModule` organization.

        .NOTES
        [Delete a repository](https://docs.github.com/rest/repos/repos#delete-a-repository)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('org')]
        [Alias('login')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repo,

        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/repos/$Owner/$Repo"
        Method      = 'DELETE'
    }

    if ($PSCmdlet.ShouldProcess("repo [$Owner/$Repo]", 'Delete')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
