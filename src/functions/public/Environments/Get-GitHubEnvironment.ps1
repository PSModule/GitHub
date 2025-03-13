filter Get-GitHubEnvironment {
    <#
        .SYNOPSIS
        List environments for a repository

        .DESCRIPTION
        List environments for a repository 
        Get an environment for a repository

        .EXAMPLE
        Get-GitHubEnvironment -Owner 'PSModule' -Repository 'Github'

        Lists all environments for the 'PSModule/GitHub' repository.

        .EXAMPLE
        Get-GitHubEnvironment -Owner 'PSModule' -Repository 'Github' -Name 'Production'

        Get the 'Production' environment for the 'PSModule/GitHub' repository.

        .NOTES
        [List environments](https://docs.github.com/en/rest/deployments/environments#list-environments)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
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
            ParameterSetName = 'NamedEnv',
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

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
            APIEndpoint = "/repos/$Owner/$Repository/environments"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ParameterSetName -eq 'NamedEnv') {
            $inputObject.APIEndpoint = "/repos/$Owner/$Repository/environments/$Name"
            $inputObject.Remove('Body')
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}