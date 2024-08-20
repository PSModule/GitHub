filter Get-GitHubRepositoryRuleSuiteById {
    <#
        .SYNOPSIS
        Get a repository rule suite

        .DESCRIPTION
        Gets information about a suite of rule evaluations from within a repository.
        For more information, see "[Managing rulesets for a repository](https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/managing-rulesets-for-a-repository#viewing-insights-for-rulesets)."

        .EXAMPLE
        Get-GitHubRepositoryRuleSuiteById -Owner 'octocat' -Repo 'hello-world' -RuleSuiteId 123456789

        Gets information about a suite of rule evaluations with ID 123456789 from within the octocat/hello-world repository.

        .NOTES
        [Get a repository rule suite](https://docs.github.com/rest/repos/rule-suites#get-a-repository-rule-suite)
    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Long links')]
    [CmdletBinding()]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The unique identifier of the rule suite result. To get this ID, you can use GET /repos/ { owner }/ { repo }/rulesets/rule-suites for repositories and GET /orgs/ { org }/rulesets/rule-suites for organizations.
        [Parameter(Mandatory)]
        [int] $RuleSuiteId

    )

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/rulesets/rule-suites/$RuleSuiteId"
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
