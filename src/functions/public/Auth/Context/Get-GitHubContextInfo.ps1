#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '5.0.4' }

function Get-GitHubContextInfo {
    <#
        .SYNOPSIS
        Lists the available GitHub contexts without getting the context data.

        .DESCRIPTION
        Lists the available GitHub contexts without getting the context data.

        .EXAMPLE
        Get-GitHubContextInfo

        Gets the current GitHub context.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'Encapsulated in a function. Never leaves as a plain text.'
    )]
    [OutputType([GitHubContext])]
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param()

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Initialize-GitHubConfig
    }

    process {
        try {
            Get-ContextInfo -ID "$($script:GitHub.Config.ID)/*"
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
