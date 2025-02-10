#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '7.0.0' }
#Requires -Modules @{ ModuleName = 'Sodium'; RequiredVersion = '2.1.2' }

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
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Initialize-GitHubConfig
    }

    process {
        Write-Verbose "Setting [$Name] to [$Value]"
        $script:GitHub.Config.$Name = $Value
        if ($PSCmdlet.ShouldProcess('ContextSetting', 'Set')) {
            Set-Context -ID $script:GitHub.Config.ID -Context $script:GitHub.Config
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
