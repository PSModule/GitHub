function Revoke-GitHubAccessToken {
    <#
        .SYNOPSIS
        Revoke a list of tokens.

        .DESCRIPTION
        Submit a list of credentials to be revoked. This endpoint is intended to revoke credentials the caller does not own and may have found
        exposed on GitHub.com or elsewhere. It can also be used for credentials associated with an old user account that you no longer have access to.
        Credential owners will be notified of the revocation.

        .LINK
        https://psmodule.io/GitHub/Functions/Auth/Revoke-GitHubAccessToken/

        .NOTES
        [Revoke a list of credentials](https://docs.github.com/rest/credentials/revoke#revoke-a-list-of-credentials)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # An array of tokens to revoke.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]] $Token
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $tokenList = [System.Collections.ArrayList]::new()
    }

    process {
        $Token | ForEach-Object {
            $tokenList.Add($_)
        }
    }

    end {
        for ($i = 0; $i -lt $tokenList.Count; $i += 1000) {
            $batch = $tokenList[$i..([Math]::Min($i + 999, $tokenList.Count - 1))]
            $body = @{ credentials = $batch }
            $InputObject = @{
                Method      = 'POST'
                APIEndpoint = '/credentials/revoke'
                Body        = $body
                Anonymous   = $true
            }
            if ($PSCmdlet.ShouldProcess('Tokens', 'Revoke')) {
                $null = Invoke-GitHubAPI @InputObject
            }
        }
        Write-Debug "[$stackPath] - End"
    }
}
#SkipTest:FunctionTest:Will add a test for this function in a future PR
