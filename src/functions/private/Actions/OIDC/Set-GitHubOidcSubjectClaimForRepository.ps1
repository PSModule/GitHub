function Set-GitHubOidcSubjectClaimForRepository {
    <#
        .SYNOPSIS
        Set the customization template for an OIDC subject claim for a repository

        .DESCRIPTION
        Creates or updates the customization template for an OpenID Connect (OIDC) subject claim for a repository.
        When UseDefault is true, the include_claim_keys are ignored by the API.

        .EXAMPLE
        ```powershell
        Set-GitHubOidcSubjectClaimForRepository -Owner 'PSModule' -Repository 'GitHub' -IncludeClaimKeys @('repo', 'context') -Context $GitHubContext
        ```

        Sets the OIDC subject claim customization template for the 'GitHub' repository.

        .EXAMPLE
        ```powershell
        Set-GitHubOidcSubjectClaimForRepository -Owner 'PSModule' -Repository 'GitHub' -UseDefault -IncludeClaimKeys @('repo') -Context $GitHubContext
        ```

        Resets the OIDC subject claim customization for the 'GitHub' repository to use the default template.

        .NOTES
        [Set the customization template for an OIDC subject claim for a repository](https://docs.github.com/en/rest/actions/oidc?apiVersion=2022-11-28#set-the-customization-template-for-an-oidc-subject-claim-for-a-repository)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # Whether to use the default subject claim template.
        # When true, the include_claim_keys are ignored by the API.
        [Parameter(Mandatory)]
        [bool] $UseDefault,

        # Array of unique strings. Each claim key can only contain alphanumeric characters and underscores.
        [Parameter(Mandatory)]
        [string[]] $IncludeClaimKeys,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        # Required permissions: Actions repo (write) or repo
    }

    process {
        $body = @{
            use_default        = $UseDefault
            include_claim_keys = $IncludeClaimKeys
        }

        $apiParams = @{
            Method      = 'PUT'
            APIEndpoint = "/repos/$Owner/$Repository/actions/oidc/customization/sub"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("OIDC subject claim for repository [$Owner/$Repository]", 'Set')) {
            $null = Invoke-GitHubAPI @apiParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
