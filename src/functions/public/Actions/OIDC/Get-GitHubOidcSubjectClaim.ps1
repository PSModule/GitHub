function Get-GitHubOidcSubjectClaim {
    <#
        .SYNOPSIS
        Get the customization template for an OIDC subject claim

        .DESCRIPTION
        Gets the customization template for an OpenID Connect (OIDC) subject claim for an organization
        or repository.

        .EXAMPLE
        ```powershell
        Get-GitHubOidcSubjectClaim -Owner 'PSModule'
        ```

        Gets the OIDC subject claim customization template for the 'PSModule' organization.

        .EXAMPLE
        ```powershell
        Get-GitHubOidcSubjectClaim -Owner 'PSModule' -Repository 'GitHub'
        ```

        Gets the OIDC subject claim customization template for the 'GitHub' repository.

        .OUTPUTS
        System.Management.Automation.PSCustomObject

        .NOTES
        [Get the customization template for an OIDC subject claim for an organization](https://docs.github.com/en/rest/actions/oidc?apiVersion=2022-11-28#get-the-customization-template-for-an-oidc-subject-claim-for-an-organization)
        [Get the customization template for an OIDC subject claim for a repository](https://docs.github.com/en/rest/actions/oidc?apiVersion=2022-11-28#get-the-customization-template-for-an-oidc-subject-claim-for-a-repository)

        .LINK
        https://psmodule.io/GitHub/Functions/Actions/OIDC/Get-GitHubOidcSubjectClaim
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [OutputType([pscustomobject])]
    [CmdletBinding(DefaultParameterSetName = 'Get the customization template for an OIDC subject claim for an organization')]
    param(
        # The account owner of the repository or the organization name. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Get the customization template for an OIDC subject claim for a repository',
            ValueFromPipelineByPropertyName)]
        [string] $Repository,

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
            'Get the customization template for an OIDC subject claim for an organization' {
                $params['Organization'] = $Owner
                Get-GitHubOidcSubjectClaimForOrganization @params
                break
            }
            'Get the customization template for an OIDC subject claim for a repository' {
                $params['Owner'] = $Owner
                $params['Repository'] = $Repository
                Get-GitHubOidcSubjectClaimForRepository @params
                break
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
