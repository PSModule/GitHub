function New-GitHubVariable {
    <#

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Scope = 'Function', Justification = 'This check is performed in the private functions.'
    )]
    [OutputType([void])]
    [CmdletBinding()]
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

        [Parameter(Mandatory)]
        [string] $Value,

        [Parameter(ParameterSetName = 'Organization')]
        [ValidateSet('private', 'selected', 'all')]
        [string] $Visibility = 'private',

        [Parameter(ParameterSetName = 'Organization')]
        [UInt64[]] $SelectedRepository,

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
                $params = @{
                    Owner              = $Owner
                    Name               = $Name
                    Value              = $Value
                    Visibility         = $Visibility
                    SelectedRepository = $SelectedRepository
                    Context            = $Context
                }
                New-GitHubVariableOnOwner @params
                break
            }
            'Repository' {
                $params = @{
                    Owner      = $Owner
                    Repository = $Repository
                    Name       = $Name
                    Value      = $Value
                    Context    = $Context
                }
                New-GitHubVariableOnRepository @params
                break
            }
            'Environment' {
                $params = @{
                    Owner       = $Owner
                    Repository  = $Repository
                    Environment = $Environment
                    Name        = $Name
                    Value       = $Value
                    Context     = $Context
                }
                New-GitHubVariableOnEnvironment @params
                break
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
