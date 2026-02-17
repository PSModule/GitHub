[CmdletBinding()]
param()

LogGroup 'AfterAll - Global Test Teardown' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    $prefix = 'Test'
    $os = $env:RUNNER_OS

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

            $repoPrefix = "$prefix-$os-$TokenType"

            LogGroup 'Repository cleanup' {
                switch ($OwnerType) {
                    'user' {
                        Get-GitHubRepository | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                    }
                    'organization' {
                        Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                    }
                }
            }
        }
    }
}
