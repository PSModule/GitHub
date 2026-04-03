function Get-GitHubOidcSubjectClaimForRepository {
    <#
        .SYNOPSIS
        Get the customization template for an OIDC subject claim for a repository

        .DESCRIPTION
        Gets the customization template for an OpenID Connect (OIDC) subject claim for a repository.

        .EXAMPLE
        ```powershell
        Get-GitHubOidcSubjectClaimForRepository -Owner 'PSModule' -Repository 'GitHub' -Context $GitHubContext
        ```

        Gets the OIDC subject claim customization template for the 'GitHub' repository.

        .NOTES
        [Get the customization template for an OIDC subject claim for a repository]
        (https://docs.github.com/rest/actions/oidc#get-the-customization-template-for-an-oidc-subject-claim-for-a-repository)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        # Required permissions: Actions repo (read) or repo
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/actions/oidc/customization/sub"
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
