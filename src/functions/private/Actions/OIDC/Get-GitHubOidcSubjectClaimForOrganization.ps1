function Get-GitHubOidcSubjectClaimForOrganization {
    <#
        .SYNOPSIS
        Get the customization template for an OIDC subject claim for an organization

        .DESCRIPTION
        Gets the customization template for an OpenID Connect (OIDC) subject claim for an organization.

        .EXAMPLE
        ```powershell
        Get-GitHubOidcSubjectClaimForOrganization -Organization 'PSModule' -Context $GitHubContext
        ```

        Gets the OIDC subject claim customization template for the 'PSModule' organization.

        .NOTES
        [Get the customization template for an OIDC subject claim for an organization]
        (https://docs.github.com/rest/actions/oidc#get-the-customization-template-for-an-oidc-subject-claim-for-an-organization)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Organization,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        # Required permissions: Administration org (read) or read:org
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/orgs/$Organization/actions/oidc/customization/sub"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
