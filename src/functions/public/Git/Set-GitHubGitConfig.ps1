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

        .LINK
        https://psmodule.io/GitHub/Functions/Git/Set-GitHubGitConfig
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $gitExists = Get-Command -Name 'git' -ErrorAction SilentlyContinue
        Write-Debug "GITEXISTS: $gitExists"
        if (-not $gitExists) {
            Write-Verbose 'Git is not installed. Cannot configure git.'
            return
        }

        $cmdresult = git rev-parse --is-inside-work-tree 2>&1
        Write-Debug "LASTEXITCODE: $LASTEXITCODE"
        Write-Debug "CMDRESULT:    $cmdresult"
        if ($LASTEXITCODE -ne 0) {
            Write-Verbose 'Not a git repository. Cannot configure git.'
            $Global:LASTEXITCODE = 0
            Write-Debug "Resetting LASTEXITCODE: $LASTEXITCODE"
            return
        }

        $username = $Context.UserName
        $id = $Context.DatabaseID
        $token = $Context.Token | ConvertFrom-SecureString -AsPlainText
        $hostName = $Context.HostName
        $installationName = $Context.InstallationName
        $sshUser = $Context.Enterprise ?? 'git'

        if ($PSCmdlet.ShouldProcess("$username on $installationName", 'Set Git configuration')) {
            $git = 'git'
            @(
                @('config', '--global', 'user.name', "$username"),
                @('config', '--global', 'user.email', "$id+$username@users.noreply.github.com"),
                @('config', '--global', '--add', "url.https://oauth2:$token@$hostName/$installationName.insteadOf",
                    "ssh://$sshUser@$hostName`:$installationName"),
                @('config', '--global', '--add', "url.https://oauth2:$token@$hostName/$installationName.insteadOf",
                    "https://$hostName/$installationName")
            ) | ForEach-Object {
                Write-Verbose "$git $($_ -join ' ')"
                & $git $_
                if ($LASTEXITCODE -ne 0) {
                    throw "Failed to run git command. ($LASTEXITCODE)"
                }
            }
        }

    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
