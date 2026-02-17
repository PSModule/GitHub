filter Get-GitHubIssueLabel {
    <#
        .SYNOPSIS
        Get labels for an issue

        .DESCRIPTION
        Lists all labels for an issue.

        .EXAMPLE
        Get-GitHubIssueLabel -Owner 'octocat' -Repository 'hello-world' -IssueNumber 1

        Lists all labels for issue #1 in the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        None

        .OUTPUTS
        GitHubLabel

        .LINK
        https://psmodule.io/GitHub/Functions/Issues/Get-GitHubIssueLabel/

        .NOTES
        [List labels for an issue](https://docs.github.com/rest/issues/labels#list-labels-for-an-issue)
    #>
    [OutputType([GitHubLabel])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The number that identifies the issue.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int] $IssueNumber,

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

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
            APIEndpoint = "/repos/$Owner/$Repository/issues/$IssueNumber/labels"
            Context     = $Context
        }

        if ($PerPage) {
            $apiParams['QueryParameters'] = @{
                per_page = $PerPage
            }
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            [GitHubLabel]::new($_.Response)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
