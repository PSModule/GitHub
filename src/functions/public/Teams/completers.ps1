Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport |
        Where-Object { $_ -like '*GitHubTeam' }) -ParameterName Slug -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $params = @{
        Organization = $fakeBoundParameters.Organization
        Context      = $fakeBoundParameters.Context
        Verbose      = $false
        Debug        = $false
    }
    Get-GitHubTeam @params | Where-Object { $_.Slug -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Slug, $_.Slug, 'ParameterValue', $_.Slug)
    }
}

Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport) -ParameterName Team -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters

    $params = @{
        Organization = $fakeBoundParameters.Organization ?? $fakeBoundParameters.Owner
        Context      = $fakeBoundParameters.Context
        Verbose      = $false
        Debug        = $false
    }
    Get-GitHubTeam @params | Where-Object { $_.Slug -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Slug, $_.Slug, 'ParameterValue', $_.Slug)
    }
}
