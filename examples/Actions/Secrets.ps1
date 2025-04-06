$Owner = 'PSModule'
$Repository = 'GitHub'
$Environment = 'test'

# Create a new environment
Set-GitHubEnvironment -Owner $Owner -Repository $Repository -Name $Environment

# Create new secrets on organization, repository and environment level
Set-GitHubSecret -Owner $Owner -Name 'TestSecret' -Value 'Organization' -Visibility all
Set-GitHubSecret -Owner $Owner -Repository $Repository -Name 'TestSecret' -Value 'Repository'
Set-GitHubSecret -Owner $Owner -Repository $Repository -Environment $Environment -Name 'TestSecret' -Value 'Environment'

# Get the secret objects (without the value)
Get-GitHubSecret -Owner $Owner -Repository $Repository -Environment $Environment -IncludeInherited -All

# Cleanup
Get-GitHubSecret -Owner $Owner -Repository $Repository -Environment $environment -IncludeInherited -All -Name 'Test*' | Remove-GitHubSecret
Get-GitHubEnvironment -Owner $Owner -Repository $Repo -Name $environment | Remove-GitHubEnvironment
