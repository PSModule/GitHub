function Disconnect-GitHubAccount {
    <#
        .SYNOPSIS
        Disconnects from GitHub and removes the current GitHub configuration.

        .DESCRIPTION
        Disconnects from GitHub and removes the current GitHub configuration.

        .EXAMPLE
        Disconnect-GitHubAccount

        Disconnects from GitHub and removes the current GitHub configuration.
    #>
    [Alias('Disconnect-GHAccount')]
    [Alias('Disconnect-GitHub')]
    [Alias('Disconnect-GH')]
    [Alias('Logout-GitHubAccount')]
    [Alias('Logout-GHAccount')]
    [Alias('Logout-GitHub')]
    [Alias('Logout-GH')]
    [Alias('Logoff-GitHubAccount')]
    [Alias('Logoff-GHAccount')]
    [Alias('Logoff-GitHub')]
    [Alias('Logoff-GH')]
    [OutputType([void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Is the CLI part of the module.')]
    [CmdletBinding()]
    param ()

    $defaultContext = Get-GitHubConfig -Name 'DefaultContext'
    Remove-Context -Name "$($script:Config.Name)/$defaultContext"
    Remove-GitHubConfig -Name 'DefaultContext'

    Write-Host '✓ ' -ForegroundColor Green -NoNewline
    Write-Host "Logged out of GitHub! [$defaultContext]"
}
