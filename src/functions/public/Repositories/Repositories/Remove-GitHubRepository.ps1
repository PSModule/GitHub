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
    #SkipTest:FunctionTest:Will add a test for this function in a future PR
    #TODO: Set high impact
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
        Write-Debug "Owner: [$Owner]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo: [$Repo]"
    }

    process {
        try {
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
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
