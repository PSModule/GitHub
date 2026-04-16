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
        $context = Connect-GitHubAccount @connectParams -PassThru -Silent
        if ($AuthType -eq 'APP') {
            $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
        }
        Write-Host ($context | Format-List | Out-String)

        foreach ($os in $osNames) {
            $repoPrefix = "Test-$os-$TokenType"
            $repoName = "$repoPrefix-$id"

            LogGroup "Repository setup - $AuthType-$TokenType - $os" {
                # Clean up repos from a previous attempt of the same run (re-runs).
                switch ($OwnerType) {
                    'user' {
                        Get-GitHubRepository | Where-Object { $_.Name -like "$repoName*" } | Remove-GitHubRepository -Confirm:$false
                    }
                    'organization' {
                        Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoName*" } | Remove-GitHubRepository -Confirm:$false
                    }
                }

                # Create the primary shared repository (with readme, license, gitignore for release tests).
                $repoParams = @{
                    Name      = $repoName
                    AddReadme = $true
                    License   = 'MIT'
                    Gitignore = 'VisualStudio'
                }
                switch ($OwnerType) {
                    'user' {
                        New-GitHubRepository @repoParams
                    }
                    'organization' {
                        New-GitHubRepository @repoParams -Organization $Owner
                    }
                }

                # Create extra repositories needed by Secrets/Variables SelectedRepository tests.
                foreach ($suffix in 2, 3) {
                    $extraName = "$repoName-$suffix"
                    switch ($OwnerType) {
                        'user' {
                            New-GitHubRepository -Name $extraName
                        }
                        'organization' {
                            New-GitHubRepository -Organization $Owner -Name $extraName
                        }
