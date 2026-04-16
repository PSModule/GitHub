# Pull Request Management Examples

# This file contains examples of how to use the Pull Request management commands.

# Prerequisites: Connect to GitHub
# Connect-GitHubAccount

# Example 1: List all open pull requests in a repository
Get-GitHubPullRequest -Owner 'PSModule' -Repository 'GitHub'

# Example 2: List all pull requests (open and closed)
Get-GitHubPullRequest -Owner 'PSModule' -Repository 'GitHub' -State 'all'

# Example 3: Get a specific pull request by number
Get-GitHubPullRequest -Owner 'PSModule' -Repository 'GitHub' -Number 123

# Example 4: Filter pull requests by head branch
Get-GitHubPullRequest -Owner 'PSModule' -Repository 'GitHub' -Head 'PSModule:feature-branch'

# Example 5: Filter pull requests by base branch
Get-GitHubPullRequest -Owner 'PSModule' -Repository 'GitHub' -Base 'main' -State 'open'

# Example 6: Sort pull requests by last update
Get-GitHubPullRequest -Owner 'PSModule' -Repository 'GitHub' -Sort 'updated' -Direction 'desc'

# Example 7: Update a pull request title and body
Update-GitHubPullRequest -Owner 'PSModule' -Repository 'GitHub' -Number 123 -Title 'New title' -Body 'Updated description'

# Example 8: Close a pull request
Update-GitHubPullRequest -Owner 'PSModule' -Repository 'GitHub' -Number 123 -State 'closed'

# Example 9: Add a comment to a pull request
New-GitHubPullRequestComment -Owner 'PSModule' -Repository 'GitHub' -Number 123 -Body 'Thanks for your contribution!'

# Example 10: Close superseded PRs with a comment (use case from the issue)
# List all open PRs with a specific head branch pattern
$oldPRs = Get-GitHubPullRequest -Owner 'PSModule' -Repository 'GoogleFonts' -Head 'PSModule:auto-update-*' -State 'open'

# Filter to get only the older ones (assuming we want to keep the most recent)
$oldPRs | Sort-Object -Property UpdatedAt | Select-Object -First ($oldPRs.Count - 1) | ForEach-Object {
    # Add a comment explaining the PR is superseded
    New-GitHubPullRequestComment -Owner $_.Owner -Repository $_.Repository -Number $_.Number -Body "This PR has been superseded by a newer Auto-Update PR and will be closed."
    
    # Close the PR
    Update-GitHubPullRequest -Owner $_.Owner -Repository $_.Repository -Number $_.Number -State 'closed'
}

# Example 11: Using pipeline to process multiple PRs
Get-GitHubPullRequest -Owner 'PSModule' -Repository 'GitHub' -State 'open' |
    Where-Object { $_.Title -like '*WIP*' } |
    New-GitHubPullRequestComment -Body 'Reminder: This PR is marked as Work In Progress'
