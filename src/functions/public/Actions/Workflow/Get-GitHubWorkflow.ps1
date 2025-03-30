filter Get-GitHubWorkflow {
    <#
        .SYNOPSIS
        Lists the workflows in a repository.

        .DESCRIPTION
        Anyone with read access to the repository can use this endpoint.
        If the repository is private you must use an access token with the repo scope.
        GitHub Apps must have the actions:read permission to use this endpoint.

        .EXAMPLE
        Get-GitHubWorkflow -Owner 'octocat' -Repository 'hello-world'

        Gets all workflows in the 'octocat/hello-world' repository.

        .EXAMPLE
        Get-GitHubWorkflow -Owner 'octocat' -Repository 'hello-world' -Name 'hello-world.yml'

        Gets the 'hello-world.yml' workflow in the 'octocat/hello-world' repository.

        .NOTES
        [List repository workflows](https://docs.github.com/rest/actions/workflows#list-repository-workflows)
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Repository,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            per_page = $PerPage
        }

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/actions/workflows"
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
