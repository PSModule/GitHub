Register-ArgumentCompleter -CommandName Get-GitHubLicense -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters

    # Try to resolve an existing default context; if none exists fall back to anonymous requests.
    $context = $fakeBoundParameters.Context ?? (Get-GitHubContext -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

    $params = @{
        Anonymous = ($null -eq $context) ? $true : $false
        Context   = ($null -ne $context) ? $context : $null
        Verbose   = $false
        Debug     = $false
    }

    Get-GitHubLicense @params | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
