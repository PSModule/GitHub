filter Set-GitHubEnvironment {
    <#
        .SYNOPSIS
        Create or update an environment.

        .DESCRIPTION
        Create or update an environment with protection rules, such as required reviewers. For more information about
        environment protection rules, see "[Environments](https://docs.github.com/actions/reference/environments#environment-protection-rules)."

        To create or update name patterns that branches must match in order to deploy to this environment, see
        "[Deployment branch policies](https://docs.github.com/rest/deployments/branch-policies)."

        To create or update secrets for an environment, see "[GitHub Actions secrets](https://docs.github.com/rest/actions/secrets)."

        OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        $params = @{
            Owner                  = "my-org"
            Repository             = "my-repo"
            Name                   = "staging"
            WaitTimer              = 30
            Reviewers              = @{ type = $user.Type; id = $user.ID }, @{ type = 'team'; id = $team.ID }
            DeploymentBranchPolicy = 'CustomBranchPolicies'
        }
        Set-GitHubEnvironment @params

        Output:
        ```powershell
        id                       : 5944178128
        node_id                  : EN_kwDOOJqfM88AAAABYkz10A
        name                     : test
        url                      : https://api.github.com/repos/PSModule/EnvironmentTest/environments/test
        html_url                 : https://github.com/PSModule/EnvironmentTest/deployments/activity_log?environments_filter=test
        created_at               : 3/16/2025 11:17:52 PM
        updated_at               : 3/16/2025 11:17:52 PM
        can_admins_bypass        : True
        protection_rules         : {@{id=30352888; node_id=GA_kwDOOJqfM84BzyX4; type=required_reviewers; prevent_self_review=False;
                                   reviewers=System.Object[]},@{id=30352889; node_id=GA_kwDOOJqfM84BzyX5; type=wait_timer; wait_timer=100},
                                   @{id=30352890; node_id=GA_kwDOOJqfM84BzyX6; type=branch_policy}}
        deployment_branch_policy : @{protected_branches=False; custom_branch_policies=True}
        ```

        Creates or updates the "staging" environment with a 30-minute wait timer.

        .OUTPUTS
        GitHubEnvironment

        .NOTES
        Returns the response object from the GitHub API call.

        .LINK
        https://psmodule.io/GitHub/Functions/Environments/Set-GitHubEnvironment/

        .LINK
        [Create or update an environment](https://docs.github.com/rest/deployments/environments#create-or-update-an-environment)
    #>
    [OutputType([GitHubEnvironment])]
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param(
        # The name of the organization.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Default'
        )]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'WithReviewers'
        )]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the Repository.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Default'
        )]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'WithReviewers'
        )]
        [string] $Repository,

        # The name of the environment.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Default'
        )]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'WithReviewers'
        )]
        [string] $Name,

        # The amount of time to delay a job after the job is initially triggered.
        # The time (in minutes) must be an integer between 0 and 43,200 (30 days).
        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'WithReviewers'
        )]
        [Alias('wait_timer')]
        [ValidateRange(0, 43200)]
        [int] $WaitTimer = 0,

        # The people or teams that may review jobs that reference the environment.
        # Must be an object with the following properties:
        # - ID: The ID of the user or team.
        # - Type: The type of reviewer. Can be either 'User' or 'Team'.
        # Example:
        # $Reviewers = @(
        #     @{ ID = 123456789; Type = 'User' },
        #     @{ ID = 987654321; Type = 'Team' }
        # )
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'WithReviewers'
        )]
        [array] $Reviewers,

        # Whether or not a user who created the job is prevented from approving their own job.
        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'WithReviewers'
        )]
        [Alias('prevent_self_review')]
        [switch] $PreventSelfReview,

        # The type of deployment branch policy for this environment.
        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'WithReviewers'
        )]
        [Alias('deployment_branch_policy')]
        [ValidateSet('ProtectedBranches', 'CustomBranchPolicies')]
        [string] $DeploymentBranchPolicy,

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
        $deploymentBranchPolicyValue = switch ($DeploymentBranchPolicy) {
            'ProtectedBranches' {
                @{
                    protected_branches     = $true
                    custom_branch_policies = $false
                }
            }
            'CustomBranchPolicies' {
                @{
                    protected_branches     = $false
                    custom_branch_policies = $true
                }
            }
            default {
                $null
            }
        }

        $body = @{
            wait_timer               = $WaitTimer
            deployment_branch_policy = $DeploymentBranchPolicyValue
        }
        if ($PSBoundParameters.ContainsKey('Reviewers')) {
            # loop through the reviewers and ensure type is User or Team. If either (case-insensitive) is found, ensure casing is User or Team.
            $reviewerList = [System.Collections.Generic.List[Object]]::new()
            foreach ($reviewer in $Reviewers) {
                switch ($reviewer.Type) {
                    'User' {
                        $reviewer.Type = 'User'
                    }
                    'Team' {
                        $reviewer.Type = 'Team'
                    }
                    default {
                        $PSCmdlet.ThrowTerminatingError(
                            [System.Management.Automation.ErrorRecord]::new(
                                [System.Exception]::new(
                                    "Invalid type '$($reviewer.Type)' for reviewer '$($reviewer.ID)'. Must be either 'User' or 'Team'."
                                ),
                                'InvalidReviewerType',
                                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                                $_
                            )
                        )
                    }
                }
                $reviewerList.Add($reviewer)
            }
            $body['reviewers'] = $reviewerList
            $body['prevent_self_review'] = [bool]$PreventSelfReview
        }

        $encodedName = [System.Uri]::EscapeDataString($Name)
        $inputObject = @{
            Method  = 'PUT'
            Uri     = $Context.ApiBaseUri + "/repos/$Owner/$Repository/environments/$encodedName"
            Body    = $body
            Context = $Context
        }

        if ($PSCmdlet.ShouldProcess("Environment [$Owner/$Repository/$Name]", 'Set')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                [GitHubEnvironment]::new($_, $Owner, $Repository)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
