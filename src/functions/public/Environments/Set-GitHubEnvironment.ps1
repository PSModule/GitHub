filter Set-GitHubEnvironment {
    <#
    .SYNOPSIS
    Create or update an environment for a repository

    .DESCRIPTION
    Create or update an environment for a repository
    
    
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
        [string] $EnvironmentName,

        # The amount of time to delay a job after the job is initially triggered. The time (in minutes).
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('wait_timer')]
        [ValidateRange(0, 43200)]
        [int] $WaitTimer,

        # Whether or not a user who created the job is prevented from approving their own job.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('prevent_self_review')]
        [switch] $PreventSelfReview,

        # The people or teams that may review jobs that reference the environment. You can list up to six users or teams as reviewers.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('reviewers')]
        [array] $Reviewers,

        # The type of deployment branch policy for this environment. To allow all branches to deploy, set to null.
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('deployment_branch_policy')]
        [object] $DeploymentBranchPolicy,

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
            wait_timer               = $WaitTimer
            prevent_self_review      = $PreventSelfReview
            reviewers                = $Reviewers
            deployment_branch_policy = $DeploymentBranchPolicy
        } | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'PUT'
            APIEndpoint = "/repos/$Owner/$Repository/environments/$EnvironmentName"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Environment [$EnvironmentName]", 'Set')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}