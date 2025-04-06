function Remove-GitHubSecret {
    <#
        .SYNOPSIS
        Deletes a secret from GitHub.

        .DESCRIPTION
        Removes a secret from a specified GitHub repository, environment, organization, or authenticated user.
        Supports both Actions and Codespaces secrets and requires appropriate authentication.

        .EXAMPLE
        Remove-GitHubSecret -Owner PSModule -Repository Demo -Type actions -Name TEST

        Deletes the secret named 'TEST' from the 'Demo' repository in the 'PSModule' organization.

        .EXAMPLE
        Remove-GitHubSecret -Organization MyOrg -Type actions -Name API_KEY

        Deletes the secret 'API_KEY' from the organization 'MyOrg'.

        .EXAMPLE
        Remove-GitHubSecret -Owner MyUser -Repository MyRepo -Environment Production -Name DB_PASSWORD

        Deletes the 'DB_PASSWORD' secret from the 'Production' environment in the 'MyRepo' repository.

        .NOTES
        Supports authentication using GitHub App tokens (IAT), Personal Access Tokens (PAT), or User Access Tokens (UAT).

        .LINK
        https://psmodule.io/GitHub/Functions/Secrets/Remove-GitHubSecret/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSShouldProcess', '', Scope = 'Function',
        Justification = 'This check is performed in the private functions.'
    )]
    [CmdletBinding(DefaultParameterSetName = 'AuthenticatedUser')]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Organization', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The name of the environment.
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Environment,

        # The name of the secret.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Name,

        # # Specifies whether the secret is for Actions or Codespaces.
        # [ValidateSet('actions', 'codespaces')]
        # [string] $Type = 'actions',

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
        Write-Debug "ParameterSet: $($PSCmdlet.ParameterSetName)"
        Write-Debug 'Parameters:'
        Get-FunctionParameter | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        switch ($PSCmdlet.ParameterSetName) {
            # 'ArrayInput' {
            #     foreach ($item in $InputObject) {
            #         if ($item.Environment) {
            #             $params = @{
            #                 Owner       = $item.Owner
            #                 Repository  = $item.Repository
            #                 Environment = $item.Environment
            #                 Context     = $Context
            #             }
            #             $existingSecrets = Get-GitHubSecretEnvironmentList @params
            #             $secretExists = $item.Name -in $existingSecrets.Name
            #             if (-not $secretExists) { continue }
            #             Remove-GitHubSecretFromEnvironment @params -Name $item.Name
            #         } elseif ($item.Repository) {
            #             $params = @{
            #                 Owner      = $item.Owner
            #                 Repository = $item.Repository
            #                 Context    = $Context
            #             }
            #             $existingSecrets = Get-GitHubSecretRepositoryList @params
            #             $secretExists = $item.Name -in $existingSecrets.Name
            #             if (-not $secretExists) { continue }
            #             Remove-GitHubSecretFromRepository @params -Name $item.Name
            #         } else {
            #             $params = @{
            #                 Owner   = $item.Owner
            #                 Context = $Context
            #             }
            #             $existingSecrets = Get-GitHubSecretOwnerList @params
            #             $secretExists = $item.Name -in $existingSecrets.Name
            #             if (-not $secretExists) { continue }
            #             Remove-GitHubSecretFromOwner @params -Name $item.Name
            #         }
            #         $scopeParam = @{
            #             Owner       = $item.Owner
            #             Repository  = $item.Repository
            #             Environment = $item.Environment
            #             Context     = $Context
            #         }
            #         $scopeParam | Remove-HashtableEntry -NullOrEmptyValues
            #         for ($i = 0; $i -le 10; $i++) {
            #             Start-Sleep -Seconds 1
            #             $secret = Get-GitHubSecret @scopeParam | Where-Object { $_.Name -eq $Name }
            #             if (-not $secret) { break }
            #         }
            #     }
            #     return
            # }
            'Organization' {
                $params = @{
                    Owner   = $Owner
                    Name    = $Name
                    Context = $Context
                }
                Remove-GitHubSecretFromOwner @params
                break
            }
            'Repository' {
                $params = @{
                    Owner      = $Owner
                    Repository = $Repository
                    Name       = $Name
                    Context    = $Context
                }
                Remove-GitHubSecretFromRepository @params
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
                Remove-GitHubSecretFromEnvironment @params
                break
            }
            'AuthenticatedUser' {
                throw 'Authenticated user: Not supported'
                break
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
