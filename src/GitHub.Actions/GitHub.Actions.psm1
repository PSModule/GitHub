
$GHAPIBaseURI = 'https://api.github.com'

function Get-GitHubContext {
    [CmdletBinding()]
    param (
        $Token = $GHToken
    )

    # API Reference
    # https://docs.github.com/en/rest/reference/users#get-the-authenticated-user
    $APICall = @{
        Uri     = "$GHAPIBaseURI/user"
        Headers = @{
            Authorization  = "token $Token"
            'Content-Type' = 'application/json'
        }
        Method  = 'GET'
        Body    = @{} | ConvertTo-Json -Depth 100
    }
    try {
        if ($PSBoundParameters.ContainsKey('Verbose')) {
            $APICall
        }
        $Response = Invoke-RestMethod @APICall
    } catch {
        throw $_
    }
    return $Response
}
