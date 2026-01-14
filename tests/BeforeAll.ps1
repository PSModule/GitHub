[CmdletBinding()]
param()

LogGroup 'BeforeAll - Global Test Setup' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    $prefix = 'Test'
    $os = $env:RUNNER_OS
    $id = $env:GITHUB_RUN_ID

    foreach ($authCase in $authCases) {
        $authCase.GetEnumerator() | ForEach-Object { Set-Variable -Name $_.Key -Value $_.Value }

        if ($TokenType -eq 'GITHUB_TOKEN') {
            Write-Host "Skipping setup for $AuthType-$TokenType (uses existing repository)"
            continue
        }

        LogGroup "Repository setup - $AuthType-$TokenType" {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            if ($AuthType -eq 'APP') {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
            }
            Write-Host ($context | Format-List | Out-String)

            $repoPrefix = "$prefix-$os-$TokenType"
            $repoName = "$repoPrefix-$id"

            switch ($OwnerType) {
                'user' {
                    Get-GitHubRepository | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                    New-GitHubRepository -Name $repoName -Confirm:$false
                }
                'organization' {
                    Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                    New-GitHubRepository -Organization $Owner -Name $repoName -Confirm:$false
                }
            }
        }
        LogGroup 'Environment setup' {
            $environmentName = "$prefix-$os-$TokenType-$id"
        }
        LogGroup 'Variables setup' {

        }
        LogGroup 'Secrets setup' {

        }
    }
}
