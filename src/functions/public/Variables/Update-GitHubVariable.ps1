function Update-GitHubVariable {
    <#
        .SYNOPSIS
        Update a GitHub variable at the organization, repository, or environment level.

        .DESCRIPTION
        Updates a GitHub Actions variable that can be referenced in workflows. This function supports updating variables
        at different levels: organization, repository, or environment. It delegates the update process to the appropriate
        private function based on the specified parameters.

        To modify an organization variable, users must have `admin:org` scope. Repository variables require `repo` scope,
        and environment variables require collaborator access.

        .EXAMPLE
        Update-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Name 'HOST_NAME' -Value 'github.com'

        Updates the repository variable named `HOST_NAME` with the value `github.com` in the specified repository.

        .EXAMPLE
        Update-GitHubVariable -Owner 'octocat' -Name 'HOST_NAME' -Value 'github.com' -Visibility 'private'

        Updates the organization variable named `HOST_NAME` with the value `github.com`, making it private.

        .EXAMPLE
        Update-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Environment 'dev' -Name 'HOST_NAME' -Value 'github.com'

        Updates the environment variable named `HOST_NAME` with the value `github.com` in the specified environment.

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/Update-GitHubVariable/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSShouldProcess', '', Scope = 'Function',
        Justification = 'This check is performed in the private functions.'
    )]
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Organization')]
        [Parameter(Mandatory, ParameterSetName = 'Repository')]
        [Parameter(Mandatory, ParameterSetName = 'Environment')]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Repository')]
        [Parameter(Mandatory, ParameterSetName = 'Environment')]
        [string] $Repository,

        # The name of the repository environment.
        [Parameter(Mandatory, ParameterSetName = 'Environment')]
        [string] $Environment,

        # The name of the variable.
        [Parameter(Mandatory)]
        [string] $Name,

        # The new name of the variable.
        [Parameter()]
        [string] $NewName,

        # The value of the variable.
        [Parameter()]
        [string] $Value,

        # The visibility of the variable when updating an organization variable.
        # Can be `private`, `selected`, or `all`.
        [Parameter(ParameterSetName = 'Organization')]
        [ValidateSet('private', 'selected', 'all')]
        [string] $Visibility = 'private',

        # The IDs of the repositories to which the variable is available.
        # Used only when the `-Visibility` parameter is set to `selected`.
        [Parameter(ParameterSetName = 'Organization')]
        [UInt64[]] $SelectedRepositories,

        # The context to run the command in. Can be either a string or a GitHubContext object.
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
        $params = @{
            Owner   = $Owner
            Name    = $Name
            Value   = $Value
            Context = $Context
        }
        if ($PSBoundParameters.ContainsKey('NewName')) {
            $params['NewName'] = $NewName
        }
        if ($PSBoundParameters.ContainsKey('Value')) {
            $params['Value'] = $Value
        }
        switch ($PSCmdlet.ParameterSetName) {
            'Organization' {
                if ($PSBoundParameters.ContainsKey('Visibility')) {
                    $params['Visibility'] = $Visibility
                }
                if ($PSBoundParameters.ContainsKey('SelectedRepositories')) {
                    $params['SelectedRepositories'] = $SelectedRepositories
                }
                Update-GitHubVariableOnOwner @params
                break
            }
            'Repository' {
                $params['Repository'] = $Repository
                Update-GitHubVariableOnRepository @params
                break
            }
            'Environment' {
                $params['Repository'] = $Repository
                $params['Environment'] = $Environment
                Update-GitHubVariableOnEnvironment @params
                break
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
