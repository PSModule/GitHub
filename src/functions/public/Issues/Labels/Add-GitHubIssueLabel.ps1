filter Add-GitHubIssueLabel {
    <#
        .SYNOPSIS
        Add labels to an issue

        .DESCRIPTION
        Adds labels to an issue.

        .EXAMPLE
        Add-GitHubIssueLabel -Owner 'octocat' -Repository 'hello-world' -IssueNumber 1 -Label 'bug', 'enhancement'

        Adds the labels 'bug' and 'enhancement' to issue #1 in the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        None

        .OUTPUTS
        GitHubLabel

        .LINK
        https://psmodule.io/GitHub/Functions/Issues/Add-GitHubIssueLabel/

        .NOTES
        [Add labels to an issue](https://docs.github.com/rest/issues/labels#add-labels-to-an-issue)
    #>
    [OutputType([GitHubLabel])]
    [CmdletBinding(SupportsShouldProcess)]
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

        # The names of the labels to add to the issue.
        [Parameter(Mandatory)]
        [string[]] $Label,

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
        if ($PSCmdlet.ShouldProcess("Issue #$IssueNumber in repository '$Owner/$Repository'", "Add labels: $($Label -join ', ')")) {
            $body = @{
                labels = $Label
            }

            $apiParams = @{
                Method      = 'POST'
                APIEndpoint = "/repos/$Owner/$Repository/issues/$IssueNumber/labels"
                Body        = $body
                Context     = $Context
            }

            Invoke-GitHubAPI @apiParams | ForEach-Object {
                [GitHubLabel]::new($_.Response)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
