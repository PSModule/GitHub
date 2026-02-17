filter Get-GitHubLabelList {
    <#
        .SYNOPSIS
        List labels for a repository

        .DESCRIPTION
        Lists all labels for a repository.

        .EXAMPLE
        Get-GitHubLabelList -Owner 'octocat' -Repository 'hello-world' -Context $context

        Lists all labels for the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        None

        .OUTPUTS
        GitHubLabel

        .NOTES
        [List labels for a repository](https://docs.github.com/rest/issues/labels#list-labels-for-a-repository)
    #>
    [OutputType([GitHubLabel])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/labels"
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
