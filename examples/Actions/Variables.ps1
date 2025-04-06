$Owner = 'marius-test2'
$Repository = 'internal'
$Environment = 'test'

# Create a new environment
Set-GitHubEnvironment -Owner $Owner -Repository $Repository -Name $environment

# Create new variables on organizaition, repository and environment level
Set-GitHubVariable -Owner $Owner -Name 'TestVariable' -Value 'Organization' -Visibility all
Get-GitHubVariable -Owner $Owner -IncludeInherited # Should have the value 'Organization'

Set-GitHubVariable -Owner $Owner -Repository $Repository -Name 'TestVariable' -Value 'Repository'
Get-GitHubVariable -Owner $Owner -Repository $Repository -IncludeInherited # Should have the value 'Repository'

Set-GitHubVariable -Owner $Owner -Repository $Repository -Environment $environment -Name 'TestVariable' -Value 'Environment'
Get-GitHubVariable -Owner $Owner -Repository $Repository -Environment $environment -IncludeInherited # Should have the value 'Environment'
Get-GitHubVariable -Owner $Owner -Repository $Repository -Environment $environment -IncludeInherited -All

# Export the variable to the local environment (good for local testing)
$env:TESTVARIABLE
Get-GitHubVariable -Owner $Owner -Repository $Repository -Environment $environment -IncludeInherited | Export-GitHubVariable
$env:TESTVARIABLE

# Cleanup
Get-GitHubVariable -Owner $Owner -Repository $Repository -Environment $environment -IncludeInherited -All -Name 'Test*' | Remove-GitHubVariable
Get-GitHubEnvironment -Owner $Owner -Repository $Repository -Name $environment | Remove-GitHubEnvironment
