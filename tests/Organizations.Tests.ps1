#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'Used to create a secure string for testing.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', '',
    Justification = 'Log outputs to GitHub Actions logs.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidLongLines', '',
    Justification = 'Long test descriptions and skip switches'
)]
[CmdletBinding()]
param()

BeforeAll {
    $testName = 'Organizations'
    $os = $env:RUNNER_OS
    $runId = $env:GITHUB_RUN_ID
    if (-not $runId) {
        throw 'GITHUB_RUN_ID is required to safely scope pre-test cleanup in Organizations.Tests.ps1.'
    }
    # GITHUB_RUN_ATTEMPT increments on each rerun (1, 2, 3...). Enterprise org names go on a
    # 90-day hold after deletion, so a rerun of the same GITHUB_RUN_ID would collide if we used
    # the run ID alone. Appending the attempt number makes each attempt produce a unique org name.
    $attempt = $env:GITHUB_RUN_ATTEMPT
    $id = $runId
    if ($attempt -and $attempt -ne '1') {
        $id = "$runId-$attempt"
    }
}

Describe 'Organizations' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Select-Object * | Out-String)
            }
            $orgPrefix = "$testName-$os-"
            $orgName = "$orgPrefix$id"

            if ($AuthType -eq 'APP') {
                $installationContext = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                LogGroup 'Context - Installation' {
                    Write-Host ($installationContext | Select-Object * | Out-String)
                }

                if ($OwnerType -eq 'enterprise') {
                    # Clean up a stale enterprise org from a previous run attempt with the same
                    # GITHUB_RUN_ID. DELETE /orgs/{org} requires org-level administration:write,
                    # so we install the app first to obtain an org-level IAT, then delete.
                    LogGroup 'Pre-test Cleanup - Stale Enterprise Organization' {
                        # On reruns, clean up any orgs from the current and previous attempts. Deleted
                        # GitHub organizations are unavailable for 90 days, so rerun attempts must use
                        # unique org names to avoid collisions. Deterministically check for stale orgs
                        # from the base run (attempt 1) and any previous rerun attempts (2, 3, etc.).
                        # Use direct lookups by name instead of enumerating all enterprise orgs to avoid
                        # API quota burn on enterprises with many organizations.

                        # Build deterministic list of org names to check: base run + previous attempts
                        $orgNamesToCheck = @("$testName-$os-$runId")  # Attempt 1
                        if ($attempt -and $attempt -ne '1') {
                            for ($attemptNum = 2; $attemptNum -le [int]$attempt; $attemptNum++) {
                                $orgNamesToCheck += "$testName-$os-$runId-$attemptNum"
                            }
                        }

                        # Check each expected org name; collect any that exist and differ from current org
                        $staleOrgs = @()
                        foreach ($candidateName in $orgNamesToCheck) {
                            if ($candidateName -ne $orgName) {
                                # Skip the current org we're about to create
                                $candidateOrg = Get-GitHubOrganization -Name $candidateName -ErrorAction SilentlyContinue
                                if ($candidateOrg -and $candidateOrg.Name) {
                                    $staleOrgs += $candidateOrg
                                }
                            }
                        }

                        if ($staleOrgs) {
                            foreach ($staleOrg in $staleOrgs) {
                                Write-Host "Stale org [$($staleOrg.Name)] found from previous run. Removing..."
                                try {
                                    # Retry Install-GitHubApp: the enterprise apps endpoint can return 404
                                    # for a short time after the org was originally created.
                                    $maxAttempts = 5
                                    $retryDelay = 3
                                    for ($retryAttempt = 1; $retryAttempt -le $maxAttempts; $retryAttempt++) {
                                        try {
                                            $null = Install-GitHubApp -Enterprise $owner -Organization $staleOrg.Name `
                                                -ClientID $installationContext.ClientID -RepositorySelection 'all' -ErrorAction Stop
                                            break
                                        } catch {
                                            if ($retryAttempt -lt $maxAttempts) {
                                                Write-Host "Install-GitHubApp attempt $retryAttempt/$maxAttempts failed: $($_.Exception.Message). Retrying in ${retryDelay}s..."
                                                Start-Sleep -Seconds $retryDelay
                                            } else {
                                                throw
                                            }
                                        }
                                    }
                                    $cleanupOrgContext = Connect-GitHubApp -Organization $staleOrg.Name -Context $context -PassThru -Silent
                                    Remove-GitHubOrganization -Name $staleOrg.Name -Confirm:$false -Context $cleanupOrgContext
                                    Write-Host "Stale org [$($staleOrg.Name)] removed."
                                } catch {
                                    # Rethrow — if the org exists but we can't remove it, New-GitHubOrganization
                                    # will fail anyway. Failing here gives a clearer root-cause message.
                                    throw "Could not remove stale org [$($staleOrg.Name)]: $($_.Exception.Message)"
                                }
                            }
                        } else {
                            Write-Host "No stale orgs found matching prefix: $orgPrefix*"
                        }
                    }
                }

                LogGroup 'Pre-test Cleanup - App Installations' {
                    Get-GitHubAppInstallation -Context $context | Where-Object { $_.Target.Name -like "$orgName*" } |
                        Uninstall-GitHubApp -Confirm:$false
                }
            }
        }

        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            Write-Host ('-' * 60)
        }

        It "Get-GitHubOrganization - Gets a specific organization 'PSModule'" {
            $organization = Get-GitHubOrganization -Name 'PSModule'
            LogGroup 'Organization' {
                Write-Host ($organization | Select-Object * | Out-String)
            }
            $organization | Should -Not -BeNullOrEmpty
            $organization | Should -BeOfType 'GitHubOrganization'
        }

        It 'GitHubOrganization.Size - Stores size in bytes (nullable UInt64)' -Skip:($OwnerType -ne 'organization') {
            $organization = Get-GitHubOrganization -Name $Owner
            LogGroup 'Organization' {
                Write-Host "$($organization | Select-Object * | Out-String)"
            }
            if ($null -ne $organization.Size) {
                $organization.Size | Should -BeOfType [System.UInt64]
            } else {
                $organization.Size | Should -BeNullOrEmpty
            }
        }

        It "Get-GitHubOrganization - List public organizations for the user 'psmodule-user'" {
            $organizations = Get-GitHubOrganization -Username 'psmodule-user'
            LogGroup 'Organization' {
                Write-Host ($organizations | Select-Object * | Out-String)
            }
            $organizations | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubOrganizationMember - Gets the members of a specific organization' -Skip:($OwnerType -in ('user', 'enterprise')) {
            $members = Get-GitHubOrganizationMember -Organization $owner
            LogGroup 'Members' {
                Write-Host ($members | Select-Object * | Out-String)
            }
            $members | Should -Not -BeNullOrEmpty
        }

        It 'Get-GitHubOrganization - Gets the organizations for the authenticated user' -Skip:($Type -eq 'GitHub Actions') {
            $orgs = Get-GitHubOrganization | Where-Object { $_.Name -like "$orgPrefix*" } | Out-String
            LogGroup 'Organizations' {
                $orgs | Format-Table -AutoSize | Out-String
            }
            { Get-GitHubOrganization } | Should -Not -Throw
        }

        It 'Update-GitHubOrganization - Sets the organization configuration' -Skip:($OwnerType -ne 'organization' -or $Type -eq 'GitHub Actions') {
            { Update-GitHubOrganization -Name $owner -Company 'ABC' } | Should -Not -Throw
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                Update-GitHubOrganization -Name $owner -BillingEmail $email
            } | Should -Not -Throw
            {
                $email = (New-Guid).Guid + '@psmodule.io'
                Update-GitHubOrganization -Name $owner -Email $email
            } | Should -Not -Throw
            { Update-GitHubOrganization -Name $owner -TwitterUsername 'PSModule' } | Should -Not -Throw
            { Update-GitHubOrganization -Name $owner -Location 'USA' } | Should -Not -Throw
            { Update-GitHubOrganization -Name $owner -Description 'Test Organization' } | Should -Not -Throw
            { Update-GitHubOrganization -Name $owner -DefaultRepositoryPermission read } | Should -Not -Throw
            { Update-GitHubOrganization -Name $owner -MembersCanCreateRepositories $true } | Should -Not -Throw
            { Update-GitHubOrganization -Name $owner -Website 'https://psmodule.io' } | Should -Not -Throw
        }

        It 'New-GitHubOrganization - Creates a new organization' -Skip:($OwnerType -ne 'enterprise') {
            $orgParam = @{
                Enterprise   = 'msx'
                Name         = $orgName
                Owner        = 'MariusStorhaug'
                BillingEmail = 'post@msx.no'
            }
            $org = New-GitHubOrganization @orgParam
            LogGroup 'Organization' {
                Write-Host ($org | Select-Object * | Out-String)
            }
            $org | Should -Not -BeNullOrEmpty
            $org | Should -BeOfType 'GitHubOrganization'
            $org.Name | Should -Be $orgName
        }

        It 'Update-GitHubOrganization - Updates the organization location using enterprise installation' -Skip:($OwnerType -ne 'enterprise') {
            { Update-GitHubOrganization -Name $orgName -Location 'New Location' } | Should -Throw
        }

        It 'Install-GitHubApp - Installs a GitHub App to an organization' -Skip:($OwnerType -ne 'enterprise') {
            # Retry: the enterprise apps endpoint can return 404 transiently right after
            # New-GitHubOrganization, before the new org has propagated.
            $maxAttempts = 5
            $retryDelay = 3
            $installation = $null
            for ($retryAttempt = 1; $retryAttempt -le $maxAttempts; $retryAttempt++) {
                try {
                    $installation = Install-GitHubApp -Enterprise $owner -Organization $orgName `
                        -ClientID $installationContext.ClientID -RepositorySelection 'all' -ErrorAction Stop
                    break
                } catch {
                    if ($retryAttempt -lt $maxAttempts) {
                        Write-Host "Install-GitHubApp attempt $retryAttempt/$maxAttempts failed: $($_.Exception.Message). Retrying in ${retryDelay}s..."
                        Start-Sleep -Seconds $retryDelay
                    } else {
                        throw
                    }
                }
            }
            LogGroup 'Installed App' {
                Write-Host ($installation | Select-Object * | Out-String)
            }
            $installation | Should -Not -BeNullOrEmpty
            $installation | Should -BeOfType 'GitHubAppInstallation'
        }

        It 'Connect-GitHubApp - Connects as a GitHub App to the organization' -Skip:($OwnerType -ne 'enterprise') {
            $orgContext = Connect-GitHubApp -Organization $orgName -Context $context -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($orgContext | Select-Object * | Out-String)
            }
            $orgContext | Should -Not -BeNullOrEmpty
        }

        It 'Update-GitHubOrganization - Updates the organization location using organization installation' -Skip:($OwnerType -ne 'enterprise') {
            $orgContext = Connect-GitHubApp -Organization $orgName -Context $context -PassThru -Silent
            Update-GitHubOrganization -Name $orgName -Location 'New Location' -Context $orgContext
        }

        It 'Remove-GitHubOrganization - Removes an organization using enterprise installation' -Skip:($OwnerType -ne 'enterprise') {
            { Remove-GitHubOrganization -Name $orgName -Confirm:$false } | Should -Throw
        }

        It 'Remove-GitHubOrganization - Removes an organization using organization installation' -Skip:($OwnerType -ne 'enterprise') {
            $orgContext = Connect-GitHubApp -Organization $orgName -Context $context -PassThru -Silent
            Remove-GitHubOrganization -Name $orgName -Confirm:$false -Context $orgContext
        }

        It 'Uninstall-GitHubApp - Removes app installation after organization deletion' -Skip:($OwnerType -ne 'enterprise') {
            LogGroup 'Post-deletion Cleanup - App Installations' {
                try {
                    $installations = Get-GitHubAppInstallation -Context $context | Where-Object { $_.Target.Name -eq $orgName }
                    foreach ($installation in $installations) {
                        Write-Host "Removing app installation ID: $($installation.ID) for deleted organization: $($installation.Target.Name)"
                        Uninstall-GitHubApp -Target $orgName -Context $context -Confirm:$false
                    }
                    $remainingInstallations = Get-GitHubAppInstallation -Context $context | Where-Object { $_.Target.Name -eq $orgName }
                    $remainingInstallations | Should -BeNullOrEmpty
                } catch {
                    Write-Host "Failed to clean up app installations after organization deletion: $($_.Exception.Message)"
                    throw
                }
            }
        }

        Context 'Invitations' -Skip:($Owner -notin 'psmodule-test-org', 'psmodule-test-org2') {
            It 'New-GitHubOrganizationInvitation - Invites a user to an organization' {
                {
                    $email = (New-Guid).Guid + '@psmodule.io'
                    New-GitHubOrganizationInvitation -Organization $owner -Email $email -Role 'admin'
                } | Should -Not -Throw
            }
            It 'Get-GitHubOrganizationPendingInvitation - Gets the pending invitations for a specific organization' {
                { Get-GitHubOrganizationPendingInvitation -Organization $owner } | Should -Not -Throw
                { Get-GitHubOrganizationPendingInvitation -Organization $owner -Role 'admin' } | Should -Not -Throw
                { Get-GitHubOrganizationPendingInvitation -Organization $owner -InvitationSource 'member' } | Should -Not -Throw
            }
            It 'Remove-GitHubOrganizationInvitation - Removes a user invitation from an organization' {
                {
                    $invitation = Get-GitHubOrganizationPendingInvitation -Organization $owner | Select-Object -First 1
                    Remove-GitHubOrganizationInvitation -Organization $owner -ID $invitation.id
                } | Should -Not -Throw
            }
        }
    }
}
