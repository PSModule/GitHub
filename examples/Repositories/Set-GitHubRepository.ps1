$params = @{
    Owner                  = 'octocat'
    Name                   = 'Hello-World'
    AllowSquashMergingWith = 'Pull request title and description'
    HasIssues              = $true
    SuggestUpdateBranch    = $true
    AllowAutoMerge         = $true
    DeleteBranchOnMerge    = $true
}
Set-GitHubRepository @params
