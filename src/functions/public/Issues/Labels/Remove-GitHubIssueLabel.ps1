filter Remove-GitHubIssueLabel {
    <#
        .SYNOPSIS
        Remove labels from an issue

        .DESCRIPTION
        Removes a label from an issue or all labels if no label name is specified.

        .EXAMPLE
        Remove-GitHubIssueLabel -Owner 'octocat' -Repository 'hello-world' -IssueNumber 1 -Name 'bug'

        Removes the label 'bug' from issue #1 in the repository 'hello-world' owned by 'octocat'.

        .EXAMPLE
        Remove-GitHubIssueLabel -Owner 'octocat' -Repository 'hello-world' -IssueNumber 1

        Removes all labels from issue #1 in the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        None

        .OUTPUTS
        None

        .LINK
        https://psmodule.io/GitHub/Functions/Issues/Remove-GitHubIssueLabel/

        .NOTES
        [Remove a label from an issue](https://docs.github.com/rest/issues/labels#remove-a-label-from-an-issue)
        [Remove all labels from an issue](https://docs.github.com/rest/issues/labels#remove-all-labels-from-an-issue)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'RemoveOne')]
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

        # The name of the label to remove. If not specified, all labels will be removed.
        [Parameter(ParameterSetName = 'RemoveOne')]
        [string] $Name,

        # Remove all labels from the issue.
        [Parameter(Mandatory, ParameterSetName = 'RemoveAll')]
        [switch] $All,

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
        $target = if ($All -or -not $Name) {
            "all labels from issue #$IssueNumber"
        } else {
            "label '$Name' from issue #$IssueNumber"
        }

        if ($PSCmdlet.ShouldProcess("Repository '$Owner/$Repository'", "Remove $target")) {
            if ($All -or -not $Name) {
                $apiParams = @{
                    Method      = 'DELETE'
                    APIEndpoint = "/repos/$Owner/$Repository/issues/$IssueNumber/labels"
                    Context     = $Context
                }
            } else {
                $apiParams = @{
                    Method      = 'DELETE'
                    APIEndpoint = "/repos/$Owner/$Repository/issues/$IssueNumber/labels/$([uri]::EscapeDataString($Name))"
                    Context     = $Context
                }
            }

            Invoke-GitHubAPI @apiParams | Out-Null
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
