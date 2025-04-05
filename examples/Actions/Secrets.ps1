$Owner = 'PSModule'
$Repository = 'GitHub'
$Environment = 'test'
$Context = Get-GitHubContext

$privateKeys = @()
$privateKeys += Get-GitHubPublicKeyForActionOnOrganization -Owner $Owner -Context $Context
$privateKeys += Get-GitHubPublicKeyForActionOnRepository -Owner $Owner -Repository $Repository -Context $Context
$privateKeys += Get-GitHubPublicKeyForActionOnEnvironment -Owner $Owner -Repository $Repository -Environment $Environment -Context $Context

$privateKeys += Get-GitHubPublicKeyForCodespacesOnOrganization -Owner $Owner -Context $Context
$privateKeys += Get-GitHubPublicKeyForCodespacesOnRepository -Owner $Owner -Repository $Repository -Context $Context
$privateKeys += Get-GitHubPublicKeyForCodespacesOnUser -Context $Context

$privateKeys | Format-Table
