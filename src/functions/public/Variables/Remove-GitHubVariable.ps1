function Remove-GitHubVariable {
    <#
        .SYNOPSIS
        Deletes a GitHub variable from an organization, repository, or environment.

        .DESCRIPTION
        Deletes a GitHub variable based on the provided scope (organization, repository, or environment).

        This function routes the request to the appropriate private function based on the provided parameters.

        Authenticated users must have collaborator access to a repository to manage variables.
        OAuth tokens and personal access tokens (classic) require specific scopes:
        - `admin:org` for organization-level variables.
        - `repo` for repository and environment-level variables.

        .EXAMPLE
        Remove-GitHubVariable -Owner 'octocat' -Name 'HOST_NAME' -Context $GitHubContext

        Deletes the specified variable from the specified organization.

        .EXAMPLE
        Remove-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Name 'HOST_NAME' -Context $GitHubContext

        Deletes the specified variable from the specified repository.

        .EXAMPLE
        Remove-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Environment 'dev' -Name 'HOST_NAME' -Context $GitHubContext

        Deletes the specified variable from the specified environment.

        .OUTPUTS
        void

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/Remove-GitHubVariable/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSShouldProcess', '', Scope = 'Function',
        Justification = 'This check is performed in the private functions.'
    )]
    [OutputType([psobject[]])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Organization', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The name of the repository environment.
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Environment,

        # The name of the variable.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
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
        switch ($PSCmdlet.ParameterSetName) {
            'Organization' {
                Remove-GitHubVariableOnOwner -Owner $Owner -Name $Name -Context $Context
                break
            }
            'Repository' {
                Remove-GitHubVariableOnRepository -Owner $Owner -Repository $Repository -Name $Name -Context $Context
                break
            }
            'Environment' {
                Remove-GitHubVariableOnEnvironment -Owner $Owner -Repository $Repository -Environment $Environment -Name $Name -Context $Context
                break
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
