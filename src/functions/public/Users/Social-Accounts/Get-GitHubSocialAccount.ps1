function Get-GitHubUserSocialAccount {
    <#
        .SYNOPSIS
        List social accounts for the authenticated user

        .DESCRIPTION
        Lists all of your social accounts.

        .EXAMPLE
        Get-GitHubUserSocialAccount

        Lists all of your social accounts.

        .NOTES
        https://docs.github.com/rest/users/social-accounts#list-social-accounts-for-the-authenticated-user
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsPaging, DefaultParameterSetName = 'AuthenticatedUser')]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ParameterSetName = 'User',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('login')]
        [string] $Username,
    
        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

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
        $irmParams = @{
            APIEndpoint     = $PScmdlet.ParameterSetName -eq 'AuthenticatedUser' ? '/user/social_accounts' : "/users/$Username/social_accounts"
            Context         = $Context
            Method          = 'GET'
            QueryParameters = @{
                per_page = $PerPage
            }
        }
        foreach($_name in 'First','Skip') {
            if ($PSBoundParameters.ContainsKey($_name)) {
                $irmParams[$_name] = $_name
            }
        }
        Invoke-GitHubRestMethod @irmParams
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
