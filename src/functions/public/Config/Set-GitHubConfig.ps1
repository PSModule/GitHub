#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '5.0.3' }

function Set-GitHubConfig {
    <#
        .SYNOPSIS
        Set a GitHub module configuration.

        .DESCRIPTION
        Set a GitHub module configuration.

        .EXAMPLE
        Set-GitHubConfig -Name DefaultUser -Value 'Octocat'

        Sets the value of DefaultUser to 'Octocat' in the GitHub module configuration.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Set the access token type.
        [Parameter()]
        [string] $Name,

        # Set the access token type.
        [Parameter()]
        [string] $Value
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
        Initialize-GitHubConfig
    }

    process {
        Write-Verbose "Setting [$Name] to [$Value]"
        $script:GitHub.Config.$Name = $Value
        try {
            if ($PSCmdlet.ShouldProcess('ContextSetting', 'Set')) {
                Set-Context -ID $script:GitHub.Config.ID -Context $script:GitHub.Config
            }
        } catch {
            Write-Error $_
            throw 'Failed to set GitHub module configuration.'
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
