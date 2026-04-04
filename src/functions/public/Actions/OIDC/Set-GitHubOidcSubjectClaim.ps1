function Set-GitHubOidcSubjectClaim {
    <#
        .SYNOPSIS
        Set the customization template for an OIDC subject claim

        .DESCRIPTION
        Creates or updates the customization template for an OpenID Connect (OIDC) subject claim for an
        organization or repository.

        For repositories, when UseDefault is true, the IncludeClaimKeys are ignored by the API.

        .EXAMPLE
        ```powershell
        Set-GitHubOidcSubjectClaim -Owner 'PSModule' -IncludeClaimKeys @('repo', 'context')
        ```

        Sets the OIDC subject claim customization template for the 'PSModule' organization.

        .EXAMPLE
        ```powershell
        Set-GitHubOidcSubjectClaim -Owner 'PSModule' -Repository 'GitHub' -IncludeClaimKeys @('repo', 'context')
        ```

        Sets the OIDC subject claim customization template for the 'GitHub' repository with custom claim keys.

        .EXAMPLE
        ```powershell
        Set-GitHubOidcSubjectClaim -Owner 'PSModule' -Repository 'GitHub' -UseDefault -IncludeClaimKeys @('repo')
        ```

        Resets the OIDC subject claim customization for the 'GitHub' repository to use the default template.

        .OUTPUTS
        System.Void

        .NOTES
        [Set the customization template for an OIDC subject claim for an organization](https://docs.github.com/en/rest/actions/oidc?apiVersion=2022-11-28#set-the-customization-template-for-an-oidc-subject-claim-for-an-organization)
        [Set the customization template for an OIDC subject claim for a repository](https://docs.github.com/en/rest/actions/oidc?apiVersion=2022-11-28#set-the-customization-template-for-an-oidc-subject-claim-for-a-repository)

        .LINK
        https://psmodule.io/GitHub/Functions/Actions/OIDC/Set-GitHubOidcSubjectClaim
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSShouldProcess', '', Scope = 'Function',
        Justification = 'This check is performed in the private functions.'
    )]
    [OutputType([void])]
    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParameterSetName = 'Set the customization template for an OIDC subject claim for an organization'
    )]
    param(
        # The account owner of the repository or the organization name. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Set the customization template for an OIDC subject claim for a repository',
            ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # Array of unique strings. Each claim key can only contain alphanumeric characters and underscores.
        [Parameter(Mandatory)]
        [string[]] $IncludeClaimKeys,

        # Whether to use the default subject claim template for the repository.
        # When true, the IncludeClaimKeys are ignored by the API.
        [Parameter(ParameterSetName = 'Set the customization template for an OIDC subject claim for a repository')]
        [switch] $UseDefault,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
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
            Context = $Context
        }

        switch ($PSCmdlet.ParameterSetName) {
            'Set the customization template for an OIDC subject claim for an organization' {
                $params['Organization'] = $Owner
                $params['IncludeClaimKeys'] = $IncludeClaimKeys
                Set-GitHubOidcSubjectClaimForOrganization @params
                break
            }
            'Set the customization template for an OIDC subject claim for a repository' {
                $params['Owner'] = $Owner
                $params['Repository'] = $Repository
                $params['IncludeClaimKeys'] = $IncludeClaimKeys
                $params['UseDefault'] = $UseDefault.IsPresent
                Set-GitHubOidcSubjectClaimForRepository @params
                break
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
