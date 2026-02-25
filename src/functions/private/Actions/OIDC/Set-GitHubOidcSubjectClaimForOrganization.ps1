function Set-GitHubOidcSubjectClaimForOrganization {
    <#
        .SYNOPSIS
        Set the customization template for an OIDC subject claim for an organization

        .DESCRIPTION
        Creates or updates the customization template for an OpenID Connect (OIDC) subject claim for an organization.

        .EXAMPLE
        ```powershell
        Set-GitHubOidcSubjectClaimForOrganization -Organization 'PSModule' -IncludeClaimKeys @('repo', 'context') -Context $GitHubContext
        ```

        Sets the OIDC subject claim customization template for the 'PSModule' organization.

        .NOTES
        [Set the customization template for an OIDC subject claim for an organization](https://docs.github.com/en/rest/actions/oidc?apiVersion=2022-11-28#set-the-customization-template-for-an-oidc-subject-claim-for-an-organization)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Organization,

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
        # Required permissions: Administration org (write) or write:org
    }

    process {
        $body = @{
            include_claim_keys = $IncludeClaimKeys
        }

        $apiParams = @{
            Method      = 'PUT'
            APIEndpoint = "/orgs/$Organization/actions/oidc/customization/sub"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("OIDC subject claim for organization [$Organization]", 'Set')) {
            $null = Invoke-GitHubAPI @apiParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
