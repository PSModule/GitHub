#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '2.0.6' }

function Get-GitHubContext {
    <#
        .SYNOPSIS
        Get the current GitHub context.

        .DESCRIPTION
        Get the current GitHub context.

        .EXAMPLE
        Get-GitHubContext

        Gets the current GitHub context.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'Encapsulated in a function. Never leaves as a plain text.'
    )]
    [OutputType([object])]
    [CmdletBinding(DefaultParameterSetName = 'CurrentContext')]
    param (
        # The name of the context.
        [Parameter(
            Mandatory,
            ParameterSetName = 'NamedContext'
        )]
        [string] $Name,

        # List all available contexts.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ListAvailableContexts'
        )]
        [switch] $ListAvailable
    )

    $contexts = if ($ListAvailable) {
        Write-Verbose "Listing available contexts. [$($script:Config.Name)/*]"
        Get-Context -Name "$($script:Config.Name)/*" -AsPlainText
    } elseif ($Name) {
        Write-Verbose "Listing available contexts. [$($script:Config.Name)/$Name]"
        Get-Context -Name "$($script:Config.Name)/$Name" -AsPlainText
    } else {
        $defaultContext = Get-GitHubConfig -Name 'DefaultContext'
        $defaultContextFullName = "$($script:Config.Name)/$defaultContext"
        Write-Verbose "Using the default context: [$defaultContextFullName]"
        Get-Context -AsPlainText | ForEach-Object {
            Write-Verbose ($_['Name'])
        }
        Get-Context -Name $defaultContextFullName -AsPlainText
    }

    Write-Verbose "Found $($contexts.Count) contexts."
    $contexts | ForEach-Object {
        Write-Verbose "Processing context: $($_['Name'])"
        $_['Name'] = $_['Name'] -replace "$($script:Config.Name)/"
        $_.Token = ConvertTo-SecureString -String $_.Token -AsPlainText
        $_.RefreshToken = ConvertTo-SecureString -String $_.Token -AsPlainText
        Write-Output $_
    }

    Remove-Variable contexts -ErrorAction SilentlyContinue
    [System.GC]::Collect()
}
