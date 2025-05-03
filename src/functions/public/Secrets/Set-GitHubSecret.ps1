#Requires -Modules @{ ModuleName = 'Sodium'; RequiredVersion = '2.1.2'}

function Set-GitHubSecret {
    <#
        .SYNOPSIS
        Updates a GitHub secret for an organization, repository, or user.

        .DESCRIPTION
        This function updates a secret in a GitHub repository, environment, or organization.
        It encrypts the secret value before storing it and supports different visibility levels.

        .EXAMPLE
        $secret = ConvertTo-SecureString "my-secret-value" -AsPlainText -Force
        Set-GitHubSecret -Repository 'MyRepo' -Owner 'MyUser' -Name 'MySecret' -Value $secret

        Updates the secret `MySecret` in the `MyRepo` repository for the owner `MyUser`.

        .EXAMPLE
        $params = @{
            Organization = 'MyOrg'
            Name         = 'MySecret'
            Type         = 'actions'
            Value        = (ConvertTo-SecureString "my-secret-value" -AsPlainText -Force)
            Private      = $true
        }
        Set-GitHubSecret @params

        Updates the secret `MySecret` at the organization level for GitHub Actions, setting visibility to private.

        .EXAMPLE
        $params = @{
            Owner      = 'MyUser'
            Repository = 'MyRepo'
            Environment = 'Production'
            Name       = 'MySecret'
            Value      = (ConvertTo-SecureString "my-secret-value" -AsPlainText -Force)
        }
        Set-GitHubSecret @params

        Updates the secret `MySecret` in the `Production` environment of the `MyRepo` repository for `MyUser`.

        .OUTPUTS
        GitHubSecret

        .LINK
        https://psmodule.io/GitHub/Functions/Secrets/Set-GitHubSecret/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSShouldProcess', '', Scope = 'Function',
        Justification = 'This check is performed in the private functions.'
    )]
    [OutputType([GitHubSecret])]
    [CmdletBinding(DefaultParameterSetName = 'Organization', SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
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

        # The name of the secret to be updated.
        [Parameter(Mandatory)]
        [string] $Name,

        # The secret value to be stored, as a SecureString or a plain string (less secure).
        [Parameter()]
        [object] $Value = (Read-Host -AsSecureString -Prompt 'Enter the secret value'),

        # The visibility of the secret when updating an organization secret.
        # Can be `private`, `selected`, or `all`.
        [Parameter(ParameterSetName = 'Organization')]
        [ValidateSet('private', 'selected', 'all')]
        [string] $Visibility = 'private',

        # The IDs of the repositories to which the secret is available.
        # Used only when the `-Visibility` parameter is set to `selected`.
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
        $publicKeyParams = @{
            Owner       = $Owner
            Repository  = $Repository
            Environment = $Environment
            Context     = $Context
        }
        $publicKeyParams | Remove-HashtableEntry -NullOrEmptyValues
        $publicKey = Get-GitHubPublicKey @publicKeyParams
        if ($Value -is [securestring]) {
            $Value = $Value | ConvertFrom-SecureString -AsPlainText
        }
        $encryptedValue = ConvertTo-SodiumSealedBox -PublicKey $publicKey.Key -Message $Value

        $params = $publicKeyParams + @{
            Name  = $Name
            Value = $encryptedValue
            KeyID = $publicKey.ID
        }

        switch ($PSCmdlet.ParameterSetName) {
            'Organization' {
                $params['Visibility'] = $Visibility
                $params['SelectedRepositories'] = $SelectedRepositories
                Set-GitHubSecretOnOwner @params
                break
            }
            'Repository' {
                Set-GitHubSecretOnRepository @params
                break
            }
            'Environment' {
                Set-GitHubSecretOnEnvironment @params
                break
            }
        }

        Get-GitHubSecret @publicKeyParams -Name $Name
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
