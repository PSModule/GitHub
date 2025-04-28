Register-ArgumentCompleter -CommandName Get-GitHubOrganization -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    if ($fakeBoundParameter.ContainsKey('Context')) {
        $orgs = Get-GitHubOrganization -Verbose:$false -Debug:$false -Context $fakeBoundParameter.Context
    } else {
        $orgs = Get-GitHubOrganization -Verbose:$false -Debug:$false
    }

    $orgs | Where-Object { $_.CompletionText -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, ($_ | Format-Table -HideTableHeaders), 'ParameterValue', $_.Description)
    }
}
