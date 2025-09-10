Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport |
        Where-Object { $_ -like '*GitHubTeam' }) -ParameterName Slug -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    $context = Resolve-GitHubContext -Context $fakeBoundParameter.Context -Verbose:$false -Debug:$false
    Get-GitHubTeam -Organization $fakeBoundParameter.Organization -Context $context -Verbose:$false -Debug:$false |
        Where-Object { $_.Slug -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.Slug, $_.Slug, 'ParameterValue', $_.Slug)
        }
}

Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport) -ParameterName Team -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters

    $context = Resolve-GitHubContext -Context $fakeBoundParameter.Context -Verbose:$false -Debug:$false
    $organization = $fakeBoundParameters.Organization ?? $fakeBoundParameters.Owner
    Get-GitHubTeam -Organization $organization -Context $context -Verbose:$false -Debug:$false |
        Where-Object { $_.Slug -like "*$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.Slug, $_.Slug, 'ParameterValue', $_.Slug)
        }
}
