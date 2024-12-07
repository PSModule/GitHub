﻿function Disconnect-GitHubAccount {
    <#
        .SYNOPSIS
        Disconnects from GitHub and removes the GitHub context.

        .DESCRIPTION
        Disconnects from GitHub and removes the GitHub context.

        .EXAMPLE
        Disconnect-GitHubAccount

        Disconnects from GitHub and removes the default GitHub context.

        .EXAMPLE
        Disconnect-GithubAccount -Context 'github.com/Octocat'

        Disconnects from GitHub and removes the context 'github.com/Octocat'.
    #>
    [Alias(
        'Disconnect-GHAccount',
        'Disconnect-GitHub',
        'Disconnect-GH',
        'Logout-GitHubAccount',
        'Logout-GHAccount',
        'Logout-GitHub',
        'Logout-GH',
        'Logoff-GitHubAccount',
        'Logoff-GHAccount',
        'Logoff-GitHub',
        'Logoff-GH'
    )]
    [OutputType([void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Is the CLI part of the module.')]
    [CmdletBinding()]
    param(
        # Silently disconnects from GitHub.
        [Parameter()]
        [Alias('Quiet')]
        [Alias('q')]
        [Alias('s')]
        [switch] $Silent,

        # The context to log out of.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    Remove-GitHubContext -Context $Context
    $isDefaultContext = $Context -eq (Get-GitHubConfig -Name 'DefaultContext')
    if ($isDefaultContext) {
        Remove-GitHubConfig -Name 'DefaultContext'
        Write-Warning 'There is no longer a default context!'
        Write-Warning "Please set a new default context using 'Set-GitHubDefaultContext -Name <context>'"
    }

    if (-not $Silent) {
        Write-Host '✓ ' -ForegroundColor Green -NoNewline
        Write-Host "Logged out of GitHub! [$Context]"
    }

    Write-Verbose "[$commandName] - End"
}
