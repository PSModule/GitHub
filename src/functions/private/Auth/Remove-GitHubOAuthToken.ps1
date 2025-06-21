function Remove-GitHubOAuthToken {
    <#
        .SYNOPSIS
        Prepares the API call to revoke an OAuth application token.

        .DESCRIPTION
        Creates the input object for revoking an OAuth application token via the GitHub API.

        .PARAMETER ClientID
        The Client ID of the OAuth application.

        .PARAMETER Token
        The access token to revoke.

        .PARAMETER Context
        The GitHub context to use for the API call.

        .OUTPUTS
        System.Collections.Hashtable
        Returns a hashtable with the API call parameters and target description.
    #>
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $ClientID,

        [Parameter(Mandatory)]
        [string] $Token,

        [Parameter(Mandatory)]
        [object] $Context
    )

    return @{
        InputObject       = @{
            Method      = 'DELETE'
            APIEndpoint = "/applications/$ClientID/token"
            Body        = @{
                access_token = $Token
            }
            Context     = $Context
        }
        TargetDescription = "OAuth token for application [$ClientID]"
    }
}