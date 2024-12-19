#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '5.0.5' }

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
        try {
            Write-Verbose "Setting [$Name] to [$Value]"
            $script:GitHub.Config.$Name = $Value
            if ($PSCmdlet.ShouldProcess('ContextSetting', 'Set')) {
                Set-Context -ID $script:GitHub.Config.ID -Context $script:GitHub.Config
            }
        } catch {
            Write-Error $_
            throw 'Failed to set GitHub module configuration.'
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
