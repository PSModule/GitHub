filter Enable-GitHubRepositorySecurityFix {
    <#
        .SYNOPSIS
        Enable automated security fixes

        .DESCRIPTION
        Enables automated security fixes for a repository. The authenticated user must have admin access to the repository.
        For more information, see
        "[Configuring automated security fixes](https://docs.github.com/articles/configuring-automated-security-fixes)".

        .EXAMPLE
        Enable-GitHubRepositorySecurityFix -Owner 'PSModule' -Repo 'GitHub'

        Enables automated security fixes for the repository.

        .NOTES
        [Enable automated security fixes](https://docs.github.com/rest/repos/repos#enable-automated-security-fixes)

    #>
    [CmdletBinding(SupportsShouldProcess)]
    [Alias('Enable-GitHubRepositorySecurityFixes')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

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
        APIEndpoint = "/repos/$Owner/$Repo/automated-security-fixes"
        Method      = 'PUT'
    }

    if ($PSCmdlet.ShouldProcess("Security Fixes for [$Owner/$Repo]", 'Enable')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
