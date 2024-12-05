function Resolve-GitHubContext {
    <#
        .SYNOPSIS
        Resolves the context into a GitHubContext object.

        .DESCRIPTION
        This function resolves the context into a GitHubContext object.
        It can take both the

        .EXAMPLE
        $Context = Resolve-GitHubContext -Context 'github.com/Octocat'

        This will resolve the context 'github.com/Octocat' into a GitHubContext object.

        .EXAMPLE
        $Context = Resolve-GitHubContext -Context $GitHubContext

        This will return the GitHubContext object.
    #>
    [OutputType([GitHubContext])]
    [CmdletBinding()]
    param(
        # The context to resolve into an object. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    if ($Context -is [GitHubContext]) {
        return $Context
    }

    if ([string]::IsNullOrEmpty($Context)) {
        throw "No contexts has been specified. Please provide a context or log in using 'Connect-GitHub'."
    }

    if ($Context -is [string]) {
        $contextName = $Context
        Write-Debug "Getting context: [$contextName]"
        $Context = Get-GitHubContext -Context $contextName
    }

    if (-not $Context) {
        throw "Context [$contextName] not found. Please provide a valid context or log in using 'Connect-GitHub'."
    }

    return $Context
}
