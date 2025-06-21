function Remove-GitHubInstallationToken {
    <#
        .SYNOPSIS
        Prepares the API call to revoke an installation access token.

        .DESCRIPTION
        Creates the input object for revoking an installation access token via the GitHub API.

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
        [object] $Context
    )

    return @{
        InputObject       = @{
            Method      = 'DELETE'
            APIEndpoint = '/installation/token'
            Context     = $Context
        }
        TargetDescription = 'Installation access token'
    }
}