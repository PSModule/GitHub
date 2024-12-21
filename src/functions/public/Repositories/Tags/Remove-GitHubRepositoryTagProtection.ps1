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
    #SkipTest:FunctionTest:Will add a test for this function in a future PR
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
                APIEndpoint = "/repos/$Owner/$Repo/tags/protection/$TagProtectionId"
                Method      = 'DELETE'
            }

            if ($PSCmdlet.ShouldProcess("tag protection state with ID [$TagProtectionId] for repository [$Owner/$Repo]", 'Delete')) {
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
