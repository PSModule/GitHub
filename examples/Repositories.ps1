$param = @{
    Name        = 'test-repo2'
    Description = 'This is a test repository'
    Visibility  = 'Public'
    AddReadme   = $true
    GitIgnore   = 'VisualStudio'
    License     = 'mit'
    HasIssues   = $true
    HasWiki     = $false
    HasProjects = $false
}

New-GitHubRepository @param -Debug

$repo = Get-GitHubRepository -Name 'test-repo2'
$repo2 = Update-GitHubRepository -Name 'test-repo2' -Homepage 'https://example123.com'

$diff = $repo | Compare-PSCustomObject $repo2 -OnlyChanged
$diff.Property | Should -BeIn ('Homepage', 'UpdatedAt')


