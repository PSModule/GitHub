
Register-ArgumentCompleter -CommandName Connect-GitHubApp -ParameterName User -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-GitHubAppInstallation -Verbose:$false | Where-Object { $_.target_type -eq 'User' -and $_.account.login -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.account.login, $_.account.login, 'ParameterValue', $_.account.login)
        }
}
Register-ArgumentCompleter -CommandName Connect-GitHubApp -ParameterName Organization -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-GitHubAppInstallation -Verbose:$false | Where-Object { $_.target_type -eq 'Organization' -and $_.account.login -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.account.login, $_.account.login, 'ParameterValue', $_.account.login)
        }
}
Register-ArgumentCompleter -CommandName Connect-GitHubApp -ParameterName Enterprise -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-GitHubAppInstallation -Verbose:$false | Where-Object { $_.target_type -eq 'Enterprise' -and $_.account.slug -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.account.slug, $_.account.slug, 'ParameterValue', $_.account.slug)
        }
}
