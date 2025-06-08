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

        .OUTPUTS
        GitHubVariable

        .NOTES
        Returns an GitHubVariable object containing details about the environment variable,
        including its name, value, associated repository, and environment details.

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/Update-GitHubVariable/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSShouldProcess', '', Scope = 'Function',
        Justification = 'This check is performed in the private functions.'
    )]
    [OutputType([GitHubVariable])]
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
        [string] $Visibility,

        # The IDs of the repositories to which the variable is available.
        # Used only when the `-Visibility` parameter is set to `selected`.
        [Parameter(ParameterSetName = 'Organization')]
        [UInt64[]] $SelectedRepositories,

        # If specified, the function will return the updated variable object.
        [Parameter()]
        [switch] $PassThru,

        # The context to run the command in. Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $params = @{
            Owner                = $Owner
            Repository           = $Repository
            Environment          = $Environment
            Name                 = $Name
            Context              = $Context
            NewName              = $NewName
            Value                = $Value
            SelectedRepositories = $SelectedRepositories
            ErrorAction          = 'Stop'
        }
        $params | Remove-HashtableEntry -NullOrEmptyValues
        switch ($PSCmdlet.ParameterSetName) {
            'Organization' {
                if ($PSBoundParameters.ContainsKey('Visibility') -and -not [string]::IsNullOrEmpty($Visibility)) {
                    $params.Visibility = $Visibility
                }
                Update-GitHubVariableOnOwner @params
                break
            }
            'Repository' {
                Update-GitHubVariableOnRepository @params
                break
            }
            'Environment' {
                Update-GitHubVariableOnEnvironment @params
                break
            }
        }
        if ($PassThru) {
            $params = @{
                Owner       = $Owner
                Repository  = $Repository
                Environment = $Environment
                Name        = $PSBoundParameters.ContainsKey('NewName') ? $NewName : $Name
                Context     = $Context
            }
            $params | Remove-HashtableEntry -NullOrEmptyValues
            for ($i = 0; $i -le 5; $i++) {
                Start-Sleep -Seconds 1
                $result = Get-GitHubVariable @params
                if ($result) { break }
            }
            $result
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
