Register-ArgumentCompleter -CommandName Get-GitHubLicense -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters

    $params = @{
        Context = $fakeBoundParameters.Context ?? (Get-GitHubContext -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
        Verbose = $false
        Debug   = $false
    }

    Get-GitHubLicense @params | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
