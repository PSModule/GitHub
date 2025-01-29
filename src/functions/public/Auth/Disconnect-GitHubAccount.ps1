function Disconnect-GitHubAccount {
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
        # Suppresses the output of the function.
        [Parameter()]
        [Alias('Quiet')]
        [Alias('q')]
        [Alias('s')]
        [switch] $Silent,

        # The context to run the command with.
        # Can be either a string or a GitHubContext object.
        [Parameter(ValueFromPipeline)]
        [object[]] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        if (-not $Context) {
            $Context = Get-GitHubContext
        }
        foreach ($contextItem in $Context) {
            $contextItem = Resolve-GitHubContext -Context $contextItem
            try {
                Remove-GitHubContext -Context $contextItem
                $isDefaultContext = $contextItem.Name -eq $script:GitHub.Config.DefaultContext
                if ($isDefaultContext) {
                    Remove-GitHubConfig -Name 'DefaultContext'
                    Write-Warning 'There is no longer a default context!'
                    Write-Warning "Please set a new default context using 'Set-GitHubDefaultContext -Name <context>'"
                }

                if (-not $Silent) {
                    Write-Host '✓ ' -ForegroundColor Green -NoNewline
                    Write-Host "Logged out of GitHub! [$contextItem]"
                }
            } catch {
                throw $_
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
