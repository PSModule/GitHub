function Set-GitHubVariable {
    <#
        .SYNOPSIS
        Creates or updates a GitHub Actions variable at the organization, repository, or environment level.

        .DESCRIPTION
        This function checks if a GitHub Actions variable exists at the specified level (organization, repository, or environment).
        If the variable exists, it updates it with the new value. If it does not exist, it creates a new variable.

        - Organization-level variables require the `admin:org` scope for OAuth tokens and personal access tokens (classic). If the repository is
          private, the `repo` scope is also required.
        - Repository-level variables require the `repo` scope.
        - Environment-level variables require collaborator access to the repository.

        .EXAMPLE
        Set-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Name 'HOST_NAME' -Value 'github.com' -Context $GitHubContext

        Creates or updates a repository variable named `HOST_NAME` with the value `github.com` in the specified repository.

        .EXAMPLE
        Set-GitHubVariable -Owner 'octocat' -Name 'HOST_NAME' -Value 'github.com' -Visibility 'all' -Context $GitHubContext

        Creates or updates an organization variable named `HOST_NAME` with the value `github.com` and
        makes it available to all repositories in the organization.

        .EXAMPLE
        Set-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Environment 'dev' -Name 'HOST_NAME' -Value 'github.com' -Context $GitHubContext

        Creates or updates an environment variable named `HOST_NAME` with the value `github.com` in the specified environment.

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/Set-GitHubVariable/
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
        $getParams = @{
            Owner       = $Owner
            Repository  = $Repository
            Environment = $Environment
            Name        = $Name
            Context     = $Context
        }
        $getParams | Remove-HashtableEntry -NullOrEmptyValues

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
        if ($PSCmdlet.ParameterSetName -eq 'Organization') {
            $params.Visibility = $Visibility
        }
        $params | Remove-HashtableEntry -NullOrEmptyValues

        $variable = Get-GitHubVariable @getParams -ErrorAction SilentlyContinue

        if ($variable) {
            $null = Update-GitHubVariable @params
        } else {
            $null = New-GitHubVariable @params
        }

        Get-GitHubVariable @getParams
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
