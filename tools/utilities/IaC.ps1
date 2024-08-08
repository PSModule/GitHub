
function Repository {
    param(
        [string] $Name,
        [hashtable] $InputObject
    )
    $exists = Get-GitHubRepository

    if ($exists) {
        Set-GitHubRepository -WhatIf:$WhatIf
    } else {
        New-GitHubRepository -WhatIf:$WhatIf
    }

    $repo = Get-GitHubRepository
    New-Variable -Name $Name -Value $repo -Scope Script -Force

    if ($Destroy) {
        Delete-GitHubRepository -WhatIf:$WhatIf
    }
}

function RuleSet {
    param(
        [string] $Name,
        [hashtable] $Rules
    )
    Write-Host "Creating RuleSet $Name"
    $Rules
}

Repository 'MyRepo' @{
    Name        = 'MyRepo'
    Description = 'MyRepo Description'
    Visibility  = 'public'
    HasIssues   = $true
    RuleSets    = @{
        Default = RuleSet @{
            Name  = 'Default'
            Rules = @{
                rule1 = @{
                    'rule1' = 'rule1'
                }
            }
        }
    }
}

$MyRepo
