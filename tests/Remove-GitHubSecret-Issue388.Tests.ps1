# Focused test for issue #388 - Cannot pipe a secret to Remove-Secret
# This test verifies the fix for piping GitHubSecret objects to Remove-GitHubSecret

Describe 'Remove-GitHubSecret ArrayInput Parameter Set Fix' {
    Context 'When piping GitHubSecret objects with different scopes' {
        BeforeAll {
            # Mock the private functions to avoid actual API calls
            Mock Remove-GitHubSecretFromOwner { 
                Write-Output "Remove-GitHubSecretFromOwner called with Owner: $Owner, Name: $Name"
            }
            Mock Remove-GitHubSecretFromRepository { 
                Write-Output "Remove-GitHubSecretFromRepository called with Owner: $Owner, Repository: $Repository, Name: $Name"
            }
            Mock Remove-GitHubSecretFromEnvironment { 
                Write-Output "Remove-GitHubSecretFromEnvironment called with Owner: $Owner, Repository: $Repository, Environment: $Environment, Name: $Name"
            }
            
            # Create mock GitHubSecret objects for testing
            $orgSecret = [PSCustomObject]@{
                Name = 'ORG_SECRET'
                Owner = 'myorg'
                Repository = ''
                Environment = ''
                Scope = 'Organization'
            }
            $orgSecret.PSObject.TypeNames.Insert(0, 'GitHubSecret')
            
            $repoSecret = [PSCustomObject]@{
                Name = 'REPO_SECRET'
                Owner = 'myorg'
                Repository = 'myrepo'
                Environment = ''
                Scope = 'Repository'
            }
            $repoSecret.PSObject.TypeNames.Insert(0, 'GitHubSecret')
            
            $envSecret = [PSCustomObject]@{
                Name = 'ENV_SECRET'
                Owner = 'myorg'
                Repository = 'myrepo'
                Environment = 'production'
                Scope = 'Environment'
            }
            $envSecret.PSObject.TypeNames.Insert(0, 'GitHubSecret')
        }
        
        It 'Should handle organization-scoped secrets correctly' {
            { $orgSecret | Remove-GitHubSecret } | Should -Not -Throw
            
            Should -Invoke Remove-GitHubSecretFromOwner -Times 1 -ParameterFilter {
                $Owner -eq 'myorg' -and $Name -eq 'ORG_SECRET'
            }
            Should -Invoke Remove-GitHubSecretFromRepository -Times 0
            Should -Invoke Remove-GitHubSecretFromEnvironment -Times 0
        }
        
        It 'Should handle repository-scoped secrets correctly' {
            { $repoSecret | Remove-GitHubSecret } | Should -Not -Throw
            
            Should -Invoke Remove-GitHubSecretFromRepository -Times 1 -ParameterFilter {
                $Owner -eq 'myorg' -and $Repository -eq 'myrepo' -and $Name -eq 'REPO_SECRET'
            }
            Should -Invoke Remove-GitHubSecretFromOwner -Times 0
            Should -Invoke Remove-GitHubSecretFromEnvironment -Times 0
        }
        
        It 'Should handle environment-scoped secrets correctly' {
            { $envSecret | Remove-GitHubSecret } | Should -Not -Throw
            
            Should -Invoke Remove-GitHubSecretFromEnvironment -Times 1 -ParameterFilter {
                $Owner -eq 'myorg' -and $Repository -eq 'myrepo' -and $Environment -eq 'production' -and $Name -eq 'ENV_SECRET'
            }
            Should -Invoke Remove-GitHubSecretFromOwner -Times 0
            Should -Invoke Remove-GitHubSecretFromRepository -Times 0
        }
        
        It 'Should handle multiple secrets with different scopes' {
            $allSecrets = @($orgSecret, $repoSecret, $envSecret)
            
            { $allSecrets | Remove-GitHubSecret } | Should -Not -Throw
            
            Should -Invoke Remove-GitHubSecretFromOwner -Times 1
            Should -Invoke Remove-GitHubSecretFromRepository -Times 1
            Should -Invoke Remove-GitHubSecretFromEnvironment -Times 1
        }
        
        It 'Should handle whitespace-only properties correctly' {
            $whitespaceSecret = [PSCustomObject]@{
                Name = 'WHITESPACE_TEST'
                Owner = 'myorg'
                Repository = 'myrepo'
                Environment = '   '  # Whitespace-only
                Scope = 'Repository'
            }
            $whitespaceSecret.PSObject.TypeNames.Insert(0, 'GitHubSecret')
            
            { $whitespaceSecret | Remove-GitHubSecret } | Should -Not -Throw
            
            # Should be treated as repository scope since Environment is whitespace
            Should -Invoke Remove-GitHubSecretFromRepository -Times 1 -ParameterFilter {
                $Name -eq 'WHITESPACE_TEST'
            }
        }
        
        It 'Should throw error when Owner is missing' {
            $invalidSecret = [PSCustomObject]@{
                Name = 'INVALID_SECRET'
                Owner = ''
                Repository = 'myrepo'
                Environment = 'production'
            }
            $invalidSecret.PSObject.TypeNames.Insert(0, 'GitHubSecret')
            
            { $invalidSecret | Remove-GitHubSecret } | Should -Throw "Unable to determine scope for secret 'INVALID_SECRET'. Owner must be specified."
        }
    }
}