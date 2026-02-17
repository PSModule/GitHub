filter Set-GitHubIssueLabel {
    <#
        .SYNOPSIS
        Set labels for an issue

        .DESCRIPTION
        Replaces all labels on an issue with the specified labels. Removes any labels not included in the Label array.

        .EXAMPLE
        Set-GitHubIssueLabel -Owner 'octocat' -Repository 'hello-world' -IssueNumber 1 -Label 'bug', 'documentation'

        Replaces all labels on issue #1 with 'bug' and 'documentation' in the repository 'hello-world' owned by 'octocat'.

        .EXAMPLE
        Set-GitHubIssueLabel -Owner 'octocat' -Repository 'hello-world' -IssueNumber 1 -Label @()

        Removes all labels from issue #1 in the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        None

        .OUTPUTS
        GitHubLabel

        .LINK
        https://psmodule.io/GitHub/Functions/Issues/Set-GitHubIssueLabel/

        .NOTES
        [Set labels for an issue](https://docs.github.com/rest/issues/labels#set-labels-for-an-issue)
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

        # The names of the labels to set for the issue. Pass an empty array to remove all labels.
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
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
        $labelText = if ($Label.Count -eq 0) { 'none' } else { $Label -join ', ' }
        if ($PSCmdlet.ShouldProcess("Issue #$IssueNumber in repository '$Owner/$Repository'", "Set labels to: $labelText")) {
            $body = @{
                labels = $Label
            }

            $apiParams = @{
                Method      = 'PUT'
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
