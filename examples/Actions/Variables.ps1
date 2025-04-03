$owner = 'marius-test2'
$repo = 'internal'
$environment = 'test'

Set-GitHubEnvironment -Owner $Owner -Repository $Repo -Name $environment

Set-GitHubVariable -Owner $Owner -Name 'TestVariable' -Value 'Organization' -Visibility all
Get-GitHubVariable -Owner $Owner -IncludeInherited # Should have the value 'Organization'

Set-GitHubVariable -Owner $Owner -Repository $Repo -Name 'TestVariable' -Value 'Repository'
Get-GitHubVariable -Owner $Owner -Repository $Repo -IncludeInherited # Should have the value 'Repository'

Set-GitHubVariable -Owner $Owner -Repository $Repo -Environment $environment -Name 'TestVariable' -Value 'Environment'
Get-GitHubVariable -Owner $Owner -Repository $Repo -Environment $environment -IncludeInherited # Should have the value 'Environment'
Get-GitHubVariable -Owner $Owner -Repository $Repo -Environment $environment -IncludeInherited -All

$env:TESTVARIABLE
Get-GitHubVariable -Owner $Owner -Repository $Repo -Environment $environment -IncludeInherited -SetLocalEnvironment
$env:TESTVARIABLE

Get-GitHubVariable -Owner $Owner -Repository $Repo -Environment $environment -IncludeInherited -All -Name 'Test*' | Remove-GitHubVariable
Get-GitHubEnvironment -Owner $Owner -Repository $Repo -Name $environment | Remove-GitHubEnvironment
