function New-GitHubVariable {
    <#
        .SYNOPSIS
        Creates a GitHub Actions variable at the organization, repository, or environment level.

        .DESCRIPTION
        This function creates a GitHub Actions variable that can be referenced in a workflow. The variable can be scoped to an organization,
        repository, or environment.

        - Organization-level variables require the `admin:org` scope for OAuth tokens and personal access tokens (classic). If the repository is
          private, the `repo` scope is also required.
        - Repository-level variables require the `repo` scope.
        - Environment-level variables require collaborator access to the repository.

        .EXAMPLE
        New-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Name 'HOST_NAME' -Value 'github.com' -Context $GitHubContext

        Creates a new repository variable named `HOST_NAME` with the value `github.com` in the specified repository.

        .EXAMPLE
        New-GitHubVariable -Owner 'octocat' -Name 'HOST_NAME' -Value 'github.com' -Visibility 'all' -Context $GitHubContext

        Creates a new organization variable named `HOST_NAME` with the value `github.com` and
        makes it available to all repositories in the organization.

        .EXAMPLE
        New-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Environment 'dev' -Name 'HOST_NAME' -Value 'github.com' -Context $GitHubContext

        Creates a new environment variable named `HOST_NAME` with the value `github.com` in the specified environment.

        .OUTPUTS
        GitHubVariable

        .NOTES
        Returns an GitHubVariable object containing details about the environment variable,
        including its name, value, associated repository, and environment details.


        .LINK
        https://psmodule.io/GitHub/Functions/Variables/New-GitHubVariable/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSShouldProcess', '', Scope = 'Function',
        Justification = 'This check is performed in the private functions.'
    )]
    [OutputType([GitHubVariable])]
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

        # The value of the variable.
        [Parameter(Mandatory)]
        [string] $Value,

        # The visibility of the variable. Can be `private`, `selected`, or `all`.
        # `private` - The variable is only available to the organization.
        # `selected` - The variable is available to selected repositories.
        # `all` - The variable is available to all repositories in the organization.
        [Parameter(ParameterSetName = 'Organization')]
        [ValidateSet('private', 'selected', 'all')]
        [string] $Visibility = 'private',

        # The IDs of the repositories to which the variable is available.
        # This parameter is only used when the `-Visibility` parameter is set to `selected`.
        [Parameter(ParameterSetName = 'Organization')]
        [UInt64[]] $SelectedRepositories,

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
        $params = @{
            Owner                = $Owner
            Repository           = $Repository
            Environment          = $Environment
            Name                 = $Name
            Value                = $Value
            SelectedRepositories = $SelectedRepositories
            Context              = $Context
            ErrorAction          = 'Stop'
        }
        $params | Remove-HashtableEntry -NullOrEmptyValues
        $null = switch ($PSCmdlet.ParameterSetName) {
            'Organization' {
                $params.Visibility = $Visibility
                New-GitHubVariableOnOwner @params
                break
            }
            'Repository' {
                New-GitHubVariableOnRepository @params
                break
            }
            'Environment' {
                New-GitHubVariableOnEnvironment @params
                break
            }
        }
        $params = @{
            Owner       = $Owner
            Repository  = $Repository
            Environment = $Environment
            Name        = $Name
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

    end {
        Write-Debug "[$stackPath] - End"
    }
}
