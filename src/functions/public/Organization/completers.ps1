Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport |
        Where-Object { $_ -like '*GitHubOrganization' }) -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $params = @{
        Context = $fakeBoundParameters.Context
        Verbose = $false
        Debug   = $false
    }
    Get-GitHubOrganization @params | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}

Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport) -ParameterName Owner -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $params = @{
        Context = $fakeBoundParameters.Context
        Verbose = $false
        Debug   = $false
    }
    Get-GitHubOrganization @params | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}

Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport) -ParameterName Organization -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $params = @{
        Context = $fakeBoundParameters.Context
        Verbose = $false
        Debug   = $false
    }
    Get-GitHubOrganization @params | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
