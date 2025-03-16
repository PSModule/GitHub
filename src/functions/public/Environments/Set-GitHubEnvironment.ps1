filter Set-GitHubEnvironment {
    <#
        .SYNOPSIS
        Create or update an environment

        .DESCRIPTION
        Create or update an environment with protection rules, such as required reviewers. For more information about environment protection rules,
        see "[Environments](/actions/reference/environments#environment-protection-rules)."

        > [!NOTE]
        > To create or update name patterns that branches must match in order to deploy to this environment, see
        "[Deployment branch policies](/rest/deployments/branch-policies)."

        > [!NOTE]
        > To create or update secrets for an environment, see "[GitHub Actions secrets](/rest/actions/secrets)."

        OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.


        .LINK
        [Create or update an environment](https://docs.github.com/rest/deployments/environments#create-or-update-an-environment)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
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
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

        # The amount of time to delay a job after the job is initially triggered.
        # The time (in minutes) must be an integer between 0 and 43,200 (30 days).
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('wait_timer')]
        [ValidateRange(0, 43200)]
        [int] $WaitTimer,

        # Whether or not a user who created the job is prevented from approving their own job.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('prevent_self_review')]
        [switch] $PreventSelfReview,

        # The people or teams that may review jobs that reference the environment. You can list up to six users or teams as reviewers. The reviewers
        # must have at least read access to the repository. Only one of the required reviewers needs to approve the job for it to proceed.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('reviewers')]
        [array] $Reviewers,

        # The type of deployment branch policy for this environment. To allow all branches to deploy, set to null.
        [parameter(ValueFromPipelineByPropertyName)]
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
            prevent_self_review      = $PreventSelfReview
            reviewers                = $Reviewers
            deployment_branch_policy = $deploymentBranchPolicyValue
        } | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'PUT'
            APIEndpoint = "/repos/$Owner/$Repository/environments/$Name"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Environment [$Owner/$Repository/$Name]", 'Set')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
