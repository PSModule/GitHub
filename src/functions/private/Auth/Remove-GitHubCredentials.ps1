function Remove-GitHubCredentials {
    <#
        .SYNOPSIS
        Prepares the API call to revoke multiple credentials using bulk revocation.

        .DESCRIPTION
        Creates the input object for revoking multiple credentials via the GitHub API bulk revocation endpoint.

        .PARAMETER Credentials
        An array of credentials to revoke.

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
        [string[]] $Credentials,

        [Parameter(Mandatory)]
        [object] $Context
    )

    return @{
        InputObject       = @{
            Method      = 'POST'
            APIEndpoint = '/credentials/revoke'
            Body        = @{
                credentials = $Credentials
            }
            Context     = $Context
        }
        TargetDescription = "$($Credentials.Count) credential(s)"
    }
}