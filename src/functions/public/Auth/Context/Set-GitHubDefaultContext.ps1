function Set-GitHubDefaultContext {
    <#
        .SYNOPSIS
        Set the default context.

        .DESCRIPTION
        Set the default context for the GitHub module.

        .EXAMPLE
        Set-GitHubDefaultContext -Context 'github.com/Octocat'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The context to set as the default.
        [Parameter(Mandatory)]
        [Alias('Name')]
        [string] $Context
    )

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    if ($PSCmdlet.ShouldProcess("$Context", 'Set default context')) {
        Set-GitHubConfig -Name 'DefaultContext' -Value $Context
    }

    Write-Verbose "[$commandName] - End"
}

Register-ArgumentCompleter -CommandName Set-GitHubDefaultContext -ParameterName Context -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    $defaultContext = Get-GitHubConfig -Name 'DefaultContext'
    $contexts = Get-GitHubContext -ListAvailable -Verbose:$false | Where-Object { "$($_.HostName)/$($_.UserName)" -ne $defaultContext }

    $contexts | Where-Object { "$($_.HostName)/$($_.UserName)" -like "$wordToComplete*" } |
        ForEach-Object {
            $contextID = "$($_.HostName)/$($_.UserName)"
            [System.Management.Automation.CompletionResult]::new($contextID, $contextID, 'ParameterValue', $contextID)
        }
}
