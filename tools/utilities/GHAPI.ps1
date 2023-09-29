# API Authorization
# https://docs.github.com/en/rest/overview/other-authentication-methods


# https://docs.github.com/en/rest/overview/resources-in-the-rest-api
# https://docs.github.com/en/rest/reference

$GHOwner = 'Org'
$GHRepo = 'RepoA'
$GHToken = 'ABC123'

$GHAPIBaseURI = 'https://api.github.com'

Function Get-GHActionRuns {
    [CmdletBinding()]
    param ()

    # API Reference
    # https://docs.github.com/en/rest/reference/actions#list-workflow-runs-for-a-repository
    $APICall = @{
        Uri     = "$GHRepoURI/repos/$GHOwner/$GHRepo/actions/runs"
        Headers = @{
            Authorization  = "token $GHToken"
            'Content-Type' = 'application/json'
        }
        Method  = 'GET'
        Body    = @{} | ConvertTo-Json -Depth 100
    }
    try {
        $response = Invoke-RestMethod @APICall
    } catch {
        throw $_
    }
    return $response.value
}
