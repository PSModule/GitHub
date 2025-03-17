function Remove-GitHubVariable {
    <#
        .SYNOPSIS
        Deletes a GitHub variable from an organization, repository, or environment.

        .DESCRIPTION
        Deletes a GitHub variable based on the provided scope (organization, repository, or environment).

        Supports pipeline input from Get-GitHubVariable or direct array input.

        Authenticated users must have collaborator access to a repository to manage variables.
        OAuth tokens and personal access tokens (classic) require specific scopes:
        - `admin:org` for organization-level variables.
        - `repo` for repository and environment-level variables.

        .EXAMPLE
        Get-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' | Remove-GitHubVariable

        Removes all variables retrieved from the specified repository.

        .EXAMPLE
        Remove-GitHubVariable -Owner 'octocat' -Name 'HOST_NAME' -Context $GitHubContext

        Deletes the specified variable from the specified organization.

        .EXAMPLE
        Remove-GitHubVariable -Variable $variablesArray

        Removes all variables provided in the array.

        .INPUTS
        GitHubVariable

        .OUTPUTS
        void

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/Remove-GitHubVariable/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSShouldProcess', '', Scope = 'Function',
        Justification = 'This check is performed in the private functions.'
    )]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Organization', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Repository,

        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Environment,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [object] $Context = (Get-GitHubContext),

        [Parameter(Mandatory, ParameterSetName = 'ArrayInput', ValueFromPipeline)]
        [GitHubVariable[]] $InputObject
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ArrayInput' {
                foreach ($item in $InputObject) {
                    if ($item.Environment) {
                        $params = @{
                            Owner       = $item.Owner
                            Repository  = $item.Repository
                            Environment = $item.Environment
                            Name        = $item.Name
                            Context     = $Context
                        }
                        Remove-GitHubVariableOnEnvironment @params
                    } elseif ($item.Repository) {
                        $params = @{
                            Owner      = $item.Owner
                            Repository = $item.Repository
                            Name       = $item.Name
                            Context    = $Context
                        }
                        Remove-GitHubVariableOnRepository @params
                    } else {
                        $params = @{
                            Owner   = $item.Owner
                            Name    = $item.Name
                            Context = $Context
                        }
                        Remove-GitHubVariableOnOwner @params
                    }
                }
            }
            'Organization' {
                $params = @{
                    Owner   = $Owner
                    Name    = $Name
                    Context = $Context
                }
                Remove-GitHubVariableOnOwner @params
            }
            'Repository' {
                $params = @{
                    Owner      = $Owner
                    Repository = $Repository
                    Name       = $Name
                    Context    = $Context
                }
                Remove-GitHubVariableOnRepository @params
            }
            'Environment' {
                $params = @{
                    Owner       = $Owner
                    Repository  = $Repository
                    Environment = $Environment
                    Name        = $Name
                    Context     = $Context
                }
                Remove-GitHubVariableOnEnvironment @params
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
