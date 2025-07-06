filter Get-GitHubEnvironmentList {
    <#
        .SYNOPSIS
        Lists the environments for a repository.

        .DESCRIPTION
        Lists the environments available in a specified GitHub repository.
        Anyone with read access to the repository can use this endpoint.
        OAuth app tokens and personal access tokens (classic) need the `repo` scope
        to use this endpoint with a private repository.

        .EXAMPLE
        Get-GitHubEnvironmentList -Owner 'PSModule' -Repository 'EnvironmentTest'

        Output:
        ```pwsh
        id                       : 5944178128
        node_id                  : EN_kwDOOJqfM88AAAABYkz10A
        name                     : test
        url                      : https://api.github.com/repos/PSModule/EnvironmentTest/environments/test
        html_url                 : https://github.com/PSModule/EnvironmentTest/deployments/activity_log?environments_filter=test
        created_at               : 3/16/2025 11:17:52 PM
        updated_at               : 3/16/2025 11:17:52 PM
        can_admins_bypass        : True
        protection_rules         : {@{id=30352888; node_id=GA_kwDOOJqfM84BzyX4; type=required_reviewers; prevent_self_review=False;
                                   reviewers=System.Object[]}, @{id=30352889; node_id=GA_kwDOOJqfM84BzyX5; type=wait_timer; wait_timer=100},
                                   @{id=30352890; node_id=GA_kwDOOJqfM84BzyX6; type=branch_policy}}
        deployment_branch_policy : @{protected_branches=False; custom_branch_policies=True}
        ```

        Lists all environments available in the "EnvironmentTest" repository owned by "PSModule".

        .OUTPUTS
        GitHubEnvironment[]

        .NOTES
        Contains details of each environment in the repository, including its name and protection settings.

        .NOTES
        [List environments](https://docs.github.com/rest/deployments/environments#list-environments)
    #>
    [OutputType([GitHubEnvironment[]])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
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
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/environments"
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            foreach ($environment in $_.Response.environments) {
                [GitHubEnvironment]::new($environment, $Owner, $Repository, $Context)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
