function Set-GitHubVariable {
    <#
     .SYNOPSIS
    Creates/Updates a GitHub variable for a Organisation, Repository or Environment.

    .DESCRIPTION
    Creates/Updates a GitHub variable for a Organisation, Repository or Environment.

    .PARAMETER Owner
    The account owner of the repository. The name is not case-sensitive.

    .PARAMETER Repository
    The name of the repository. The name is not case-sensitive.

    .PARAMETER Environment
    The name of the repository environment.

    .PARAMETER Name
    The name of the variable.

    .PARAMETER Value
    The value of the variable.

    .PARAMETER Private
    Set visibility to private (only applicable at the organization level).

    .PARAMETER SelectedRepositoryIds
    List of numeric repository IDs where the variable should be visible (only applicable at the organization level).

    .PARAMETER Context
    The context to run the command in. Used to get the details for the API call.

    .EXAMPLE
    Sets a variable in an environment.
    Set-GitHubVariable -Owner "octocat" -Repository "Hello-World" -Environment "dev" -Name "myVariable" -Value "myValue"

    .EXAMPLE
    Sets a variable in a repository.
    Set-GitHubVariable -Owner "octocat" -Repository "Hello-World" -Name "myVariable" -Value "myValue"

    .EXAMPLE
    Sets a variable in an organisation.
    Set-GitHubVariable -Owner "octocat" -Name "myVariable" -Value "myValue"

    .EXAMPLE 
    Sets a variable in an organisation with visibility set to private.
    Set-GitHubVariable -Owner "octocat" -Name "myVariable" -Value "myValue" -Private

    .EXAMPLE
    Sets a variable in an organisation with visibility set to selected repositories.
    Set-GitHubVariable -Owner "octocat" -Name "myVariable" -Value "myValue" -SelectedRepositoryIds 123456, 654362

    .NOTES
    [Create an organization variable](https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#create-an-organization-variable)
    [Create a repository variable](https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#create-a-repository-variable)
    [Create an environment variable](https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#create-an-environment-variable)
    [Update an organization variable](https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#update-an-organization-variable)
    [Update a repository variable](https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#update-a-repository-variable)
    [Update an environment variable](https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#update-an-environment-variable)

    .OUTPUTS
    psobject[]

    #>
    [OutputType([psobject[]])]
    [CmdletBinding(SupportsShouldProcess)]
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
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Value,

        [Parameter(ParameterSetName = 'Organization')]
        [switch] $Private,

        [Parameter(ParameterSetName = 'Organization')]
        [int[]] $SelectedRepositoryIDs,

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
        $getParams = $PSBoundParameters
        $getParams | Remove-HashtableEntry -NullOrEmptyValues -RemoveNames 'Value','Private','SelectedRepositoryIDs','Context' 
        $variableFound = Get-GitHubVariable @getParams -Name $Name 

        $body = @{
            name  = $Name
            value = $Value
        }

        if ($PSCmdlet.ParameterSetName -eq 'Organization') {
            if ($PSBoundParameters.ContainsKey('SelectedRepositoryIDs')) {
                $body['selected_repository_ids'] = @($SelectedRepositoryIDs)
                $body['visibility'] = 'selected'
            }
            elseif($Private) {
                $body['visibility'] = 'private'
            }
            else{
                $body['visibility'] = 'all'
            }
        }

        $inputObject = @{
            Method      = "Post"
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
            Body        = $body
            Context     = $Context
        }

        if ($variableFound) {   
                $inputObject.Method = "PATCH"
                $inputObject.APIEndpoint = $inputObject.APIEndpoint + "/$Name"
        }

        if($PSCmdlet.ShouldProcess("Variable [$Name]", 'CREATE/UPDATE')) {
            $result = Invoke-GitHubAPI @inputObject
            Write-Output $result.Response
        }    
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}