Register-ArgumentCompleter -CommandName Connect-GitHubApp -ParameterName User -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    $context = Resolve-GitHubContext -Context $fakeBoundParameter.Context -Verbose:$false -Debug:$false
    Get-GitHubAppInstallation -Context $context -Verbose:$false -Debug:$false |
        Where-Object { $_.Type -eq 'User' -and $_.Target.Name -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.Target.Name, $_.Target.Name, 'ParameterValue', $_.Target.Name)
        }
}
Register-ArgumentCompleter -CommandName Connect-GitHubApp -ParameterName Organization -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    $context = Resolve-GitHubContext -Context $fakeBoundParameter.Context -Verbose:$false -Debug:$false
    Get-GitHubAppInstallation -Context $context -Verbose:$false -Debug:$false |
        Where-Object { $_.Type -eq 'Organization' -and $_.Target.Name -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.Target.Name, $_.Target.Name, 'ParameterValue', $_.Target.Name)
        }
}
Register-ArgumentCompleter -CommandName Connect-GitHubApp -ParameterName Enterprise -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    $context = Resolve-GitHubContext -Context $fakeBoundParameter.Context -Verbose:$false -Debug:$false
    Get-GitHubAppInstallation -Context $context -Verbose:$false -Debug:$false |
        Where-Object { $_.Type -eq 'Enterprise' -and $_.Target.Name -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.Target.Name, $_.Target.Name, 'ParameterValue', $_.Target.Name)
        }
}
