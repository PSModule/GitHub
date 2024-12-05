function Set-GitHubGitConfig {
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
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    $gitExists = Get-Command -Name 'git' -ErrorAction SilentlyContinue
    if (-not $gitExists) {
        throw 'Git is not installed. Please install Git before running this command.'
    }

    $username = $Context.UserName
    $id = $Context.DatabaseID
    $token = $Context.Token | ConvertFrom-SecureString -AsPlainText
    $hostName = $Context.HostName

    if ($PSCmdlet.ShouldProcess("$Name", 'Set Git configuration')) {
        git config --local user.name "$username"
        git config --local user.email "$id+$username@users.noreply.github.com"
        git config --local "url.https://oauth2:$token@$hostName.insteadOf" "https://$hostName"
        Write-Verbose "[$commandName] - End"
    }
}
