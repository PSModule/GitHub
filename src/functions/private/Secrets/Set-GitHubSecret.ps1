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

        .LINK
        https://psmodule.io/GitHub/Functions/Secrets/Set-GitHubSecret/
    #>

    [CmdletBinding(DefaultParameterSetName = 'AuthenticatedUser', SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        # The account owner of the repository. The name is not case-sensitive.
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository. The name is not case-sensitive.
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string] $Repository,

        # The name of the repository environment.
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [string] $Environment,

        # The name of the secret to be updated.
        [Parameter(Mandatory)]
        [string] $Name,

        # The type of secret, either 'actions' or 'codespaces'.
        [ValidateSet('actions', 'codespaces')]
        [string] $Type = 'actions',

        # Set visibility to private (only applicable at the organization level).
        [Parameter(ParameterSetName = 'Organization')]
        [switch] $Private,

        # List of numeric repository IDs where the secret should be visible.
        [Parameter(ParameterSetName = 'AuthenticatedUser')]
        [Parameter(ParameterSetName = 'Organization')]
        [int[]] $SelectedRepositoryIDs,

        # The secret value to be stored, provided as a SecureString.
        [Parameter(Mandatory)]
        [SecureString] $Value,

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
        $apiEndPoint = switch ($PSCmdlet.ParameterSetName) {
            'Environment' {
                "/repos/$Owner/$Repository/environments/$Environment/secrets/$Name"
                break
            }
            'Organization' {
                "/orgs/$Owner/$Type/secrets/$Name"
                break
            }
            'Repository' {
                "/repos/$Owner/$Repository/$Type/secrets/$Name"
                break
            }
            'AuthenticatedUser' {
                "/user/codespaces/secrets/$Name"
                break
            }
        }
        if ($PSCmdLet.ShouldProcess(
                "Updating GitHub secret [$Name]",
                "Are you sure you want to update GitHub secret [$apiEndPoint]?",
                'Update secret'
            )) {
            # Get the Organization, Repository, or AuthenticatedUser public key for encryption
            $getPublicKeyParams = switch ($PSCmdlet.ParameterSetName) {
                'Organization' {
                    @{
                        Organization = $Owner
                        Type         = $Type
                    }
                    break
                }
                'AuthenticatedUser' {
                    @{ }
                    break
                }
                default {
                    @{
                        Owner      = $Owner
                        Repository = $Repository
                        Type       = $Type
                    }
                }
            }
            $publicKey = Get-GitHubPublicKey @getPublicKeyParams
            $body = @{
                encrypted_value = ConvertTo-SodiumSealedBox -Secret (ConvertFrom-SecureString $Value -AsPlainText) -PublicKey $publicKey.key
                key_id          = $publicKey.key_id
            }
            if ($PSCmdlet.ParameterSetName -in 'AuthenticatedUser', 'Organization') {
                if ($Private.IsPresent -and $PSCmdlet.ParameterSetName -eq 'Organization') {
                    $body['visibility'] = 'private'
                } elseif ($PSBoundParameters.ContainsKey('SelectedRepositoryIDs')) {
                    $body['selected_repository_ids'] = @($SelectedRepositoryIDs)
                    $body['visibility'] = 'selected'
                }
            }
            $putParams = @{
                APIEndpoint = $apiEndPoint
                Body        = [PSCustomObject] $body | ConvertTo-Json
                Context     = $Context
                Method      = 'PUT'
            }
            Invoke-GitHubAPI @putParams | Select-Object -ExpandProperty Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
