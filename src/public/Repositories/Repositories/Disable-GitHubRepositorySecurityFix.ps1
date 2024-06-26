﻿filter Disable-GitHubRepositorySecurityFix {
    <#
        .SYNOPSIS
        Disable automated security fixes

        .DESCRIPTION
        Disables automated security fixes for a repository. The authenticated user must have admin access to the repository.
        For more information, see
        "[Configuring automated security fixes](https://docs.github.com/articles/configuring-automated-security-fixes)".

        .EXAMPLE
        Disable-GitHubRepositorySecurityFix -Owner 'PSModule' -Repo 'GitHub'

        Disables automated security fixes for the repository.

        .NOTES
        [Disable automated security fixes](https://docs.github.com/rest/repos/repos#disable-automated-security-fixes)

    #>
    [CmdletBinding(SupportsShouldProcess)]
    [Alias('Disable-GitHubRepositorySecurityFixes')]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo)
    )

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/automated-security-fixes"
        Method      = 'DELETE'
    }

    if ($PSCmdlet.ShouldProcess("Security Fixes for [$Owner/$Repo]", 'Disable')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
