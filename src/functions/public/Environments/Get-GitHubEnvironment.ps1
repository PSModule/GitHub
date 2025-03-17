filter Get-GitHubEnvironment {
    <#
        .SYNOPSIS
        Retrieves details of a specified GitHub environment or lists all environments for a repository.

        .DESCRIPTION
        This function retrieves details of a specific environment in a GitHub repository when the `-Name` parameter
        is provided. Otherwise, it lists all available environments for the specified repository.

        Anyone with read access to the repository can use this function.
        OAuth app tokens and personal access tokens (classic) need the `repo` scope
        to use this function with a private repository.

        .EXAMPLE
        Get-GitHubEnvironment -Owner 'PSModule' -Repository 'EnvironmentTest' -Name 'test'

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

        Retrieves details of the "test" environment in the specified repository.

        .EXAMPLE
        Get-GitHubEnvironment -Owner 'PSModule' -Repository 'EnvironmentTest'

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
        PSCustomObject

        .NOTES
        Returns details of a GitHub environment or a list of environments for a repository.

        .LINK
        https://psmodule.io/GitHub/Functions/Environments/Get-GitHubEnvironment/
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        # The name of the organization.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the Repository.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Repository,

        # The name of the environment.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ByName',
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

        # The maximum number of environments to return per request.
        [Parameter(ParameterSetName = 'List')]
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
        switch ($PSCmdlet.ParameterSetName) {
            'ByName' {
                Get-GitHubEnvironmentByName -Owner $Owner -Repository $Repository -Name $Name -Context $Context
            }
            'List' {
                Get-GitHubEnvironmentList -Owner $Owner -Repository $Repository -PerPage $PerPage -Context $Context
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
