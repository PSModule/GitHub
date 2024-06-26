﻿filter Get-GitHubRepositorySecurityFix {
    <#
        .SYNOPSIS
        Check if automated security fixes are enabled for a repository

        .DESCRIPTION
        Shows whether automated security fixes are enabled, disabled or paused for a repository.
        The authenticated user must have admin read access to the repository. For more information, see
        "[Configuring automated security fixes](https://docs.github.com/articles/configuring-automated-security-fixes)".

        .EXAMPLE
        Get-GitHubRepositorySecurityFix -Owner 'PSModule' -Repo 'GitHub'

        Gets the automated security fixes status for the GitHub repository.

        .NOTES
        [Check if automated security fixes are enabled for a repository](https://docs.github.com/rest/repos/repos#check-if-automated-security-fixes-are-enabled-for-a-repository)

    #>
    [Alias('Get-GitHubRepoSecurityFixes')]
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
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
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
