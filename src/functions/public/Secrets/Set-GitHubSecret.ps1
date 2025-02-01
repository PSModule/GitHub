function Set-GitHubSecret {
    <#
    .SYNOPSIS
         Update a secret.

    .PARAMETER Organization
        The organization name. The name is not case sensitive.

    .PARAMETER Owner
        The account owner of the repository. The name is not case sensitive.

    .PARAMETER Repository
        The name of the repository. The name is not case sensitive.

    .PARAMETER Environment
        The name of the repository environment.

    .PARAMETER Name
        The name of the secret.

    .PARAMETER Type
        actions / codespaces

    .EXAMPLE
        # TODO

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#create-or-update-an-organization-secret

    .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#create-or-update-a-repository-secret

    .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#create-or-update-an-environment-secret

    .LINK
        https://docs.github.com/en/rest/codespaces/secrets?apiVersion=2022-11-28#create-or-update-a-secret-for-the-authenticated-user
    #>
    [CmdletBinding(DefaultParameterSetName = 'AuthenticatedUser', SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [string]$Organization,

        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string]$Owner,

        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string]$Repository,

        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [string]$Environment,

        [Parameter(Mandatory)]
        [string]$Name,

        [ValidateSet('actions', 'codespaces')]
        [string]$Type = 'actions',

        [Parameter(Mandatory)]
        [SecureString]$Value,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        # TODO: This check should probably be built-in to the Sodium module
        if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) {
            if (-not (Test-VisualCRedistributableInstalled -Version '14.29.30037')) {
                throw  'The libsodium library used to encrypt secrets for Set-GitHubSecret requires the Microsoft Visual C++ Redistributable for Visual Studio 2015, 2017, 2019, and 2022 to be installed on windows.'
            }
        }

        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner: [$Owner]"

        if ([string]::IsNullOrEmpty($Repository)) {
            $Repository = $Context.Repo
        }
        Write-Debug "Repository: [$Repository]"
    }

    process {
        $apiEndPoint = switch ($PSCmdlet.ParameterSetName) {
            'Environment' {
                "/repos/$Owner/$Repository/environments/$Environment/secrets/$Name"
                break
            }
            'Organization' {
                "/orgs/$Organization/$Type/secrets/$Name"
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
                "Updating github secret [$Name]",
                "Are you sure you want to update github secret [$apiEndPoint]?",
                'Update secret'
            )) {
            # Get the Organization, Repository, or AuthenticatedUser public key for encryption
            $getPublicKeyParams = switch ($PSCmdlet.ParameterSetName) {
                'Organization' {
                    @{
                        Organization = $Organization
                        Type         = $Type
                    }
                    break
                }
                'AuthenticatedUser' {
                    @{}
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
            $putParams = @{
                APIEndpoint = $apiEndPoint
                Body        = [PSCustomObject]@{
                    encrypted_value = ConvertTo-SodiumEncryptedString -Secret (ConvertFrom-SecureString $Value -AsPlainText) -PublicKey $publicKey.key
                    key_id          = $publicKey.key_id
                } | ConvertTo-Json
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

#SkipTest:FunctionTest:Will add a test for this function in a future PR
