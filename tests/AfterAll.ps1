[CmdletBinding()]
param()

LogGroup 'AfterAll - Global Test Teardown' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    $id = $env:GITHUB_RUN_ID
    $prefix = 'Test'

    # Derive the list of OS names from the Settings JSON provided by Process-PSModule.
    $settings = $env:Settings | ConvertFrom-Json
    $osNames = @($settings.TestSuites.Module.OSName | Sort-Object -Unique)
    Write-Host "Cleaning up test repositories for OSes: $($osNames -join ', ')"

    foreach ($authCase in $authCases) {
        $authCase.GetEnumerator() | ForEach-Object { Set-Variable -Name $_.Key -Value $_.Value }

        if ($TokenType -eq 'GITHUB_TOKEN') {
            Write-Host "Skipping teardown for $AuthType-$TokenType (uses existing repository)"
            continue
        }

        LogGroup "Teardown - $AuthType-$TokenType" {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            if ($AuthType -eq 'APP') {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
            }
            Write-Host ($context | Format-List | Out-String)

            foreach ($os in $osNames) {
                $repoPrefix = "$prefix-$os-$TokenType"
                $repoName = "$repoPrefix-$id"

                LogGroup "Repository cleanup - $AuthType-$TokenType - $os" {
                    switch ($OwnerType) {
                        'user' {
                            Get-GitHubRepository | Where-Object { $_.Name -like "$repoName*" } | Remove-GitHubRepository -Confirm:$false
                        }
                        'organization' {
                            Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoName*" } | Remove-GitHubRepository -Confirm:$false
                        }
                    }
                }
            }

            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }
    }
}
