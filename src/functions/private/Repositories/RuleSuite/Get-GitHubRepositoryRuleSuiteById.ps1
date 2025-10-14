filter Get-GitHubRepositoryRuleSuiteById {
    <#
        .SYNOPSIS
        Get a repository rule suite

        .DESCRIPTION
        Gets information about a suite of rule evaluations from within a repository.
        For more information, see "[Managing rulesets for a repository](https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/managing-rulesets-for-a-repository#viewing-insights-for-rulesets)."

        .EXAMPLE
        ```powershell
        Get-GitHubRepositoryRuleSuiteById -Owner 'octocat' -Repository 'hello-world' -RuleSuiteId 123456789
        ```

        Gets information about a suite of rule evaluations with ID 123456789 from within the octocat/hello-world repository.

        .NOTES
        [Get a repository rule suite](https://docs.github.com/rest/repos/rule-suites#get-a-repository-rule-suite)

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/RuleSuite/Get-GitHubRepositoryRuleSuiteById
    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Long links')]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The unique identifier of the rule suite result. To get this ID, you can use GET /repos/ { owner }/ { repo }/rulesets/rule-suites for repositories and GET /orgs/ { org }/rulesets/rule-suites for organizations.
        [Parameter(Mandatory)]
        [int] $ID,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/rulesets/rule-suites/$ID"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
