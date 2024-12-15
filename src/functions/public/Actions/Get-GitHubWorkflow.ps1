filter Get-GitHubWorkflow {
    <#
        .SYNOPSIS
        Lists the workflows in a repository.

        .DESCRIPTION
        Anyone with read access to the repository can use this endpoint.
        If the repository is private you must use an access token with the repo scope.
        GitHub Apps must have the actions:read permission to use this endpoint.

        .EXAMPLE
        Get-GitHubWorkflow -Owner 'octocat' -Repo 'hello-world'

        Gets all workflows in the 'octocat/hello-world' repository.

        .EXAMPLE
        Get-GitHubWorkflow -Owner 'octocat' -Repo 'hello-world' -Name 'hello-world.yml'

        Gets the 'hello-world.yml' workflow in the 'octocat/hello-world' repository.

        .NOTES
        [List repository workflows](https://docs.github.com/rest/actions/workflows?apiVersion=2022-11-28#list-repository-workflows)
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param(
        [Parameter()]
        [string] $Owner,

        [Parameter()]
        [string] $Repo,

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
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner : [$($Context.Owner)]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo : [$($Context.Repo)]"
    }

    process {
        try {
            $body = @{
                per_page = $PerPage
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/repos/$Owner/$Repo/actions/workflows"
                Method      = 'GET'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response.workflows
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
