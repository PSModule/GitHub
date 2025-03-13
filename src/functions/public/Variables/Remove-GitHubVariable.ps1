function Remove-GitHubVariable {
    <#
     .SYNOPSIS
    Removes a GitHub variable from an Organisation, Repository or Environment.

    .DESCRIPTION
    Removes a GitHub variable from an Organisation, Repository or Environment.

    .PARAMETER Owner
    The account owner of the repository. The name is not case-sensitive.

    .PARAMETER Repository
    The name of the repository. The name is not case-sensitive.

    .PARAMETER Environment
    The name of the repository environment.

    .PARAMETER Name
    The name of the variable.

    .PARAMETER Context
    The context to run the command in. Used to get the details for the API call.

    .EXAMPLE
    Remove-GitHubVariable -Owner "octocat" -Repository "Hello-World" -Environment "dev" -Name "myVariable"
    Remove-GitHubVariable -Owner "octocat" -Repository "Hello-World" -Name "myVariable"
    Remove-GitHubVariable -Owner "octocat" -Name "myVariable"

    .NOTES
    [Delete an Organisation Variable](https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#delete-an-organization-variable)
    [Delete a Repository Variable](https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#delete-a-repository-variable)
    [Delete an Environment Variable](https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#delete-an-environment-variable)

    .OUTPUTS
    psobject[]
    #>
    [OutputType([psobject[]])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [string] $Repository,

        # The name of the repository environment.
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [string] $Environment,

        # The name of the variable.
        
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
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
            Method      = "DELETE"
            APIEndpoint = switch ($PSCmdlet.ParameterSetName) {
                'Environment' {
                    "/repos/$Owner/$Repository/environments/$Environment/variables/$Name"
                    break
                }
                'Repository' {
                    "/repos/$Owner/$Repository/actions/variables/$Name"
                    break
                }
                'Organization' {
                    "/orgs/$Owner/actions/variables/$Name" 
                    break
                }
            }
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Variable [$Name]", 'DELETE')) {
            Invoke-GitHubAPI @inputObject | ForeEach-Object {
                Write-Output $_.Response
            } 
        }
    }

    end {
        write-Debug "[$stackPath] - End"
    }
}