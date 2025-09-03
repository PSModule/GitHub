function Set-GitHubConfig {
    <#
        .SYNOPSIS
        Set a GitHub module configuration.

        .DESCRIPTION
        Set a GitHub module configuration.

        .EXAMPLE
        Set-GitHubConfig -Name DefaultUser -Value 'Octocat'

        Sets the value of DefaultUser to 'Octocat' in the GitHub module configuration.

        .OUTPUTS
        GitHubConfig

        .LINK
        https://psmodule.io/GitHub/Functions/Config/Set-GitHubConfig
    #>
    [OutputType([GitHubConfig])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Set the access token type.
        [Parameter()]
        [string] $Name,

        # Set the access token type.
        [Parameter()]
        [string] $Value,

        # Pass the context through the pipeline.
        [Parameter()]
        [switch] $PassThru
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
            $item = Set-Context -Context $script:GitHub.Config -Vault $script:GitHub.ContextVault -PassThru:$PassThru
            if ($PassThru) {
                [GitHubConfig]::new($item)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '8.1.3' }

