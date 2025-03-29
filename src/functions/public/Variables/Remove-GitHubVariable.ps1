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
    [OutputType([void])]
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
                            Context     = $Context
                        }
                        $existingVariables = Get-GitHubVariableEnvironemntList @params
                        $variableExists = $item.Name -in $existingVariables.Name
                        if (-not $variableExists) { continue }
                        Remove-GitHubVariableFromEnvironment @params -Name $item.Name
                    } elseif ($item.Repository) {
                        $params = @{
                            Owner      = $item.Owner
                            Repository = $item.Repository
                            Context    = $Context
                        }
                        $existingVariables = Get-GitHubVariableRepositoryList @params
                        $variableExists = $item.Name -in $existingVariables.Name
                        if (-not $variableExists) { continue }
                        Remove-GitHubVariableFromRepository @params -Name $item.Name
                    } else {
                        $params = @{
                            Owner   = $item.Owner
                            Context = $Context
                        }
                        $existingVariables = Get-GitHubVariableOwnerList @params
                        $variableExists = $item.Name -in $existingVariables.Name
                        if (-not $variableExists) { continue }
                        Remove-GitHubVariableFromOwner @params -Name $item.Name
                    }
                    $scopeParam = @{
                        Owner       = $item.Owner
                        Repository  = $item.Repository
                        Environment = $item.Environment
                        Context     = $Context
                    }
                    $scopeParam | Remove-HashtableEntry -NullOrEmptyValues
                    for ($i = 0; $i -le 10; $i++) {
                        Start-Sleep -Seconds 1
                        $variable = Get-GitHubVariable @scopeParam | Where-Object { $_.Name -eq $Name }
                        if (-not $variable) { break }
                    }
                }
                return
            }
            'Organization' {
                $params = @{
                    Owner   = $Owner
                    Name    = $Name
                    Context = $Context
                }
                $existingVariables = Get-GitHubVariableOwnerList @params
                $variableExists = $Name -in $existingVariables.Name
                if (-not $variableExists) { continue }
                Remove-GitHubVariableFromOwner @params -Name $Name
                break
            }
            'Repository' {
                $params = @{
                    Owner      = $Owner
                    Repository = $Repository
                    Name       = $Name
                    Context    = $Context
                }
                $existingVariables = Get-GitHubVariableRepositoryList @params
                $variableExists = $Name -in $existingVariables.Name
                if (-not $variableExists) { continue }
                Remove-GitHubVariableFromRepository @params -Name $Name
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
                $existingVariables = Get-GitHubVariableEnvironemntList @params
                $variableExists = $Name -in $existingVariables.Name
                if (-not $variableExists) { continue }
                Remove-GitHubVariableFromEnvironment @params -Name $Name
                break
            }
        }

        $scopeParam = @{
            Owner       = $Owner
            Repository  = $Repository
            Environment = $Environment
        }
        $scopeParam | Remove-HashtableEntry -NullOrEmptyValues
        for ($i = 0; $i -le 10; $i++) {
            Start-Sleep -Seconds 1
            $variable = Get-GitHubVariable @scopeParam | Where-Object { $_.Name -eq $Name }
            if (-not $variable) { break }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
