filter Get-GitHubEnvironmentByName {
    <#
        .SYNOPSIS
        Retrieves details of a specified GitHub environment.

        .DESCRIPTION
        This function retrieves information about a specific environment in a GitHub repository.
        To get information about name patterns that branches must match in order to deploy to this environment,
        see "[Get a deployment branch policy](https://docs.github.com/rest/deployments/branch-policies#get-a-deployment-branch-policy)."

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

        .OUTPUTS
        GitHubEnvironment

        .NOTES
        Contains environment details, including name, URL, and protection settings.

        .LINK
        https://psmodule.io/GitHub/Functions/Get-GitHubEnvironmentByName/
    #>
    [OutputType([GitHubEnvironment])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Repository,

        # The name of the environment.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

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
        $encodedName = [System.Uri]::EscapeDataString($Name)
        $apiParams = @{
            Method  = 'GET'
            Uri     = $Context.ApiBaseUri + "/repos/$Owner/$Repository/environments/$encodedName"
            Context = $Context
        }
        try {
            Invoke-GitHubAPI @apiParams | ForEach-Object {
                [GitHubEnvironment]::new($_.Response, $Owner, $Repository, $Context)
            }
        } catch {
            return
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
