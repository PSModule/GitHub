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
        ```powershell
        Get-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' | Remove-GitHubVariable
        ```

        Removes all variables retrieved from the specified repository.

        .EXAMPLE
        ```powershell
        Remove-GitHubVariable -Owner 'octocat' -Name 'HOST_NAME' -Context $GitHubContext
        ```

        Deletes the specified variable from the specified organization.

        .EXAMPLE
        ```powershell
        Remove-GitHubVariable -Variable $variablesArray
        ```

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
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Organization', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The name of the environment.
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Environment,

        # The name of the variable.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Name,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context,

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
                    switch ($item.Scope) {
                        'environment' {
                            $params = @{
                                Owner       = $item.Owner
                                Repository  = $item.Repository
                                Environment = $item.Environment
                                Name        = $item.Name
                                Context     = $Context
                            }
                            Remove-GitHubVariableFromEnvironment @params
                        }
                        'repository' {
                            $params = @{
                                Owner      = $item.Owner
                                Repository = $item.Repository
                                Name       = $item.Name
                                Context    = $Context
                            }
                            Remove-GitHubVariableFromRepository @params
                        }
                        'organization' {
                            $params = @{
                                Owner   = $item.Owner
                                Name    = $item.Name
                                Context = $Context
                            }
                            Remove-GitHubVariableFromOwner @params
                        }
                        default {
                            throw "Variable '$($item.Name)' has unsupported Scope value '$($item.Scope)'."
                        }
                    }
                }
                break
            }
            'Organization' {
                $params = @{
                    Owner   = $Owner
                    Name    = $Name
                    Context = $Context
                }
                Remove-GitHubVariableFromOwner @params
                break
            }
            'Repository' {
                $params = @{
                    Owner      = $Owner
                    Repository = $Repository
                    Name       = $Name
                    Context    = $Context
                }
                Remove-GitHubVariableFromRepository @params
                break
            }
            'Environment' {
                $params = @{
                    Owner       = $Owner
                    Repository  = $Repository
                    Environment = $Environment
                    Name        = $Name
                    Context     = $Context
                }
                Remove-GitHubVariableFromEnvironment @params
                break
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
