﻿function Set-GitHubGitConfig {
    <#
        .SYNOPSIS
        Set the Git configuration for the GitHub context.

        .DESCRIPTION
        Sets the Git configuration for the GitHub context. This command sets the `user.name`, `user.email`, and `url.<host>.insteadOf` git configs.

        .EXAMPLE
        Set-GitHubGitConfig

        Sets the Git configuration for the default GitHub context.

        .EXAMPLE
        Set-GitHubGitConfig -Context 'MyContext'

        Sets the Git configuration for the GitHub context named 'MyContext'.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The context to use for the API call. This is used to retrieve the necessary configuration settings.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    $gitExists = Get-Command -Name 'git' -ErrorAction SilentlyContinue
    if (-not $gitExists) {
        throw 'Git is not installed. Please install Git before running this command.'
    }

    $contextObj = Get-GitHubContext -Name $Context
    Write-Verbose "Using GitHub context: $Context"
    if (-not $contextObj) {
        throw 'Log in using Connect-GitHub before running this command.'
    }

    $username = $contextObj.UserName
    $id = $contextObj.DatabaseID
    $token = $contextObj.Token | ConvertFrom-SecureString -AsPlainText
    $hostName = $contextObj.HostName

    if ($PSCmdlet.ShouldProcess("$Name", 'Set Git configuration')) {
        git config --global user.name "$username"
        git config --global user.email "$id+$username@users.noreply.github.com"
        git config --global "url.https://oauth2:$token@$hostName.insteadOf" "https://$hostName"
        Write-Verbose "[$commandName] - End"
    }
}