filter Remove-GitHubEnvironment {
    <#
        .SYNOPSIS
        Deletes an environment from a repository

        .DESCRIPTION
        Deletes an environment from a repository

        .EXAMPLE
        Remove-GitHubEnvironment -Owner 'PSModule' -Repository 'GitHub' -EnvironmentName 'Production'
        
        Deletes the 'Production' environment from the 'PSModule/GitHub' repository.

        .NOTES
        [Delete environments](https://docs.github.com/en/rest/deployments/environments?#delete-an-environment)
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
        $inputObject = @{
            Method      = 'DELETE'
            APIEndpoint = "/repos/$Owner/$Repository/environments/$EnvironmentName"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Environment [$EnvironmentName]", 'DELETE')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}