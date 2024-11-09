$scriptFilePath = $MyInvocation.MyCommand.Path

Write-Verbose "[$scriptFilePath] - Initializing GitHub PowerShell module..."

### This is the store config for this module
$storeParams = @{
    Name      = $script:Config.Name
    Variables = @{}
}
Set-Store @storeParams

# if ($env:GITHUB_ACTIONS -eq 'true') {
#     Initialize-RunnerEnvironment
# }
