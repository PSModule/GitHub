$Owner = 'PSModule'
$Repository = 'GitHub'
$Environment = 'test'

Set-GitHubEnvironment -Owner $Owner -Repository $Repository -Name $Environment

$publicKeys = @()
$publicKeys += Get-GitHubPublicKey -Owner $Owner
$publicKeys += Get-GitHubPublicKey -Owner $Owner -Repository $Repository
$publicKeys += Get-GitHubPublicKey -Owner $Owner -Repository $Repository -Environment $Environment

$publicKeys += Get-GitHubPublicKey -Owner $Owner -Type codespaces
$publicKeys += Get-GitHubPublicKey -Owner $Owner -Repository $Repository -Type codespaces
$publicKeys += Get-GitHubPublicKey -Type codespaces

$publicKeys | Format-Table


Set-GitHubSecret -Owner $Owner -Name 'TestSecret' -Value 'TestValue'
Set-GitHubSecret -Owner $Owner -Repository $Repository -Name 'TestSecret' -Value 'TestValue'
Set-GitHubSecret -Owner $Owner -Repository $Repository -Environment $Environment -Name 'TestSecret' -Value 'TestValue'

Get-GitHubSecret -Owner $Owner -Repository $Repository -Environment $Environment -IncludeInherited | 
