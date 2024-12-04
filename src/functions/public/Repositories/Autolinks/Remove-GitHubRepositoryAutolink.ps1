filter Remove-GitHubRepositoryAutolink {
    <#
        .SYNOPSIS
        Delete an autolink reference from a repository

        .DESCRIPTION
        This deletes a single autolink reference by ID that was configured for the given repository.

        Information about autolinks are only available to repository administrators.

        .EXAMPLE
        Remove-GitHubRepositoryAutolink -Owner 'octocat' -Repo 'Hello-World' -AutolinkId 1

        Deletes the autolink with ID 1 for the repository 'Hello-World' owned by 'octocat'.

        .NOTES
        [Delete an autolink reference from a repository](https://docs.github.com/rest/repos/autolinks#delete-an-autolink-reference-from-a-repository)

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repo,

        # The unique identifier of the autolink.
        [Parameter(Mandatory)]
        [Alias('autolink_id')]
        [Alias('ID')]
        [int] $AutolinkId,

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
        APIEndpoint = "/repos/$Owner/$Repo/autolinks/$AutolinkId"
        Method      = 'DELETE'
        Body        = $body
    }

    if ($PSCmdlet.ShouldProcess("Autolink with ID [$AutolinkId] for repository [$Owner/$Repo]", 'Delete')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
