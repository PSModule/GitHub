filter Get-GitHubMilestoneLabel {
    <#
        .SYNOPSIS
        Get labels for issues in a milestone

        .DESCRIPTION
        Lists labels for every issue in a milestone.

        .EXAMPLE
        Get-GitHubMilestoneLabel -Owner 'octocat' -Repository 'hello-world' -MilestoneNumber 1

        Lists all labels for issues in milestone #1 in the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        None

        .OUTPUTS
        GitHubLabel

        .LINK
        https://psmodule.io/GitHub/Functions/Issues/Get-GitHubMilestoneLabel/

        .NOTES
        [List labels for issues in a milestone](https://docs.github.com/rest/issues/labels#list-labels-for-issues-in-a-milestone)
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

        # The number that identifies the milestone.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int] $MilestoneNumber,

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
            APIEndpoint = "/repos/$Owner/$Repository/milestones/$MilestoneNumber/labels"
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
