[CmdletBinding()]
param()

LogGroup 'BeforeAll - Global Test Setup' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"
    $id = $env:GITHUB_RUN_ID

    # Derive the list of OS names from the Settings JSON provided by Process-PSModule.
    $settings = $env:Settings | ConvertFrom-Json
    $osNames = @($settings.TestSuites.Module.OSName | Sort-Object -Unique)
    Write-Host "Creating test repositories for OSes: $($osNames -join ', ')"

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

            foreach ($os in $osNames) {
                $repoPrefix = "Test-$os-$TokenType"
                $repoName = "$repoPrefix-$id"

                LogGroup "Repository setup - $AuthType-$TokenType - $os" {
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
            }
        }
    }
}
