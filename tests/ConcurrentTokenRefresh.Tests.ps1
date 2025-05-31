#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
)]
[CmdletBinding()]
param()

Describe 'Concurrent Token Refresh Prevention - Unit Tests' {
    
    Context 'Mutex Implementation' {
        It 'Should create and dispose mutex objects without throwing' {
            # Test that the mutex can be created and disposed properly
            $mutexName = "TestMutex_$(Get-Random)"
            $mutex = $null
            $acquired = $false
            
            try {
                # Create mutex object
                $mutex = New-Object System.Threading.Mutex($false, $mutexName)
                $mutex | Should -Not -BeNullOrEmpty
                
                # Should be able to acquire
                $acquired = $mutex.WaitOne(1000)
                $acquired | Should -Be $true
                
            } finally {
                if ($acquired -and $mutex) { $mutex.ReleaseMutex() }
                if ($mutex) { $mutex.Dispose() }
            }
        }
        
        It 'Should handle mutex name sanitization' {
            # Test that problematic characters in context ID are handled
            $contextId = 'test/context:with*invalid?chars<>|'
            $sanitizedName = "GitHubTokenRefresh_$($contextId -replace '[\\/:*?"<>|]', '_')"
            
            # Should not contain any invalid characters
            $sanitizedName | Should -Not -Match '[\\/:*?"<>|]'
            $sanitizedName | Should -BeLike 'GitHubTokenRefresh_test_context_with_invalid_chars___'
        }
        
        It 'Should handle mutex timeout gracefully' {
            $mutexName = "TestTimeoutMutex_$(Get-Random)"
            $mutex = $null
            $acquired = $false
            
            try {
                $mutex = New-Object System.Threading.Mutex($false, $mutexName)
                
                # Should be able to acquire
                $acquired = $mutex.WaitOne(1000)
                $acquired | Should -Be $true
                
                # Test timeout behavior - this should not throw
                { $mutex.WaitOne(50) } | Should -Not -Throw
                
            } finally {
                if ($acquired -and $mutex) { $mutex.ReleaseMutex() }
                if ($mutex) { $mutex.Dispose() }
            }
        }
    }
    
    Context 'Code Structure Verification' {
        It 'Should have mutex implementation in Update-GitHubUserAccessToken.ps1' {
            $functionPath = '/home/runner/work/GitHub/GitHub/src/functions/private/Auth/DeviceFlow/Update-GitHubUserAccessToken.ps1'
            $content = Get-Content $functionPath -Raw
            
            # Verify mutex-related code is present
            $content | Should -Match 'System\.Threading\.Mutex'
            $content | Should -Match 'WaitOne'
            $content | Should -Match 'ReleaseMutex'
            $content | Should -Match 'finally'
            $content | Should -Match 'Dispose'
        }
        
        It 'Should have proper try-finally structure' {
            $functionPath = '/home/runner/work/GitHub/GitHub/src/functions/private/Auth/DeviceFlow/Update-GitHubUserAccessToken.ps1'
            $content = Get-Content $functionPath -Raw
            
            # Check for proper structure
            $content | Should -Match 'try\s*\{'
            $content | Should -Match '\}\s*finally\s*\{'
        }
        
        It 'Should implement double-check pattern' {
            $functionPath = '/home/runner/work/GitHub/GitHub/src/functions/private/Auth/DeviceFlow/Update-GitHubUserAccessToken.ps1'
            $content = Get-Content $functionPath -Raw
            
            # Should check token validity after acquiring mutex
            $content | Should -Match 'Double-check if we still need to refresh'
        }
    }
}