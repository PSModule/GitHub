#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '5.0.5' }

function Get-GitHubContextInfo {
    <#
        .SYNOPSIS
        Lists the available GitHub contexts without getting the context data.

        .DESCRIPTION
        Lists the available GitHub contexts without getting the context data.

        .EXAMPLE
        Get-GitHubContextInfo

        Gets the current GitHub context.

        .EXAMPLE
        Get-GitHubContextInfo -Name 'github.com*'

        Gets the GitHub context that matches the name 'github.com*'.

        .EXAMPLE
        Get-GitHubContextInfo -Name '*/Organization/*'

        Gets the GitHub context that matches the name '*/Organization/*'.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'Encapsulated in a function. Never leaves as a plain text.'
    )]
    [OutputType([GitHubContext])]
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        # The name of the context to get.
        [Parameter()]
        [SupportsWildcards()]
        [string] $Name = '*'
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Initialize-GitHubConfig
    }

    process {
        try {
            Get-ContextInfo -ID "$($script:GitHub.Config.ID)/$Name"
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
