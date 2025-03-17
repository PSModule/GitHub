function Get-GitHubVariable {
    <#
    .SYNOPSIS
    Gets the GitHub variable details for a Organisation, Repository or Environment.

    .DESCRIPTION
    Gets the GitHub variable details for a Organisation, Repository or Environment.

    .PARAMETER Owner
    The account owner of the repository. The name is not case-sensitive.

    .PARAMETER Repository
    The name of the repository. The name is not case-sensitive.

    .PARAMETER Environment
    The name of the repository environment.

    .PARAMETER Name
    The name of the variable. If left blank, all variable names are returned.

    .PARAMETER Context
    The context to run the command in. Used to get the details for the API call.

    .EXAMPLE
    Get-GitHubVariable -Owner "octocat" -Repository "Hello-World" -Environment "dev"
    Get-GitHubVariable -Owner "octocat" -Repository "Hello-World" -Name "myVariable"
    Get-GitHubVariable -Owner "octocat" -Name "myVariable"

    .NOTES
    [Gets an Organisation Variable](https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#get-an-organization-variable)
    [Gets an Repository Variable](https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#get-a-repository-variable)
    [Gets an Environment Variable](https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#get-an-environment-variable)

    .OUTPUTS
    psobject[]

    #>
    [OutputType([psobject[]])]
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string] $Repository,

        # The name of the repository environment.
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [string] $Environment,

        # The name of the variable.
        [Parameter()]
        [string] $Name,

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
            Method      = 'Get'
            APIEndpoint = switch ($PSCmdlet.ParameterSetName) {
                'Environment' {
                    "/repos/$Owner/$Repository/environments/$Environment/variables"
                    break
                }
                'Repository' {
                    "/repos/$Owner/$Repository/actions/variables"
                    break
                }
                'Organization' {
                    "/orgs/$Owner/actions/variables"
                    break
                }
            }
            Context     = $Context
        }

        if (-not [string]::IsNullOrWhiteSpace($Name)) {
            $inputObject.APIEndpoint += "/$Name"
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
